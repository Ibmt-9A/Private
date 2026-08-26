codeunit 51000 NALVideoAnalysisMgt
{
    var
        VideoTooLargeLbl: Label 'The video file is %1 MB which exceeds the maximum allowed size of %2 MB. Please use a shorter recording.', Comment = '%1 = actual size in MB, %2 = max size in MB';
        VideoNotUploadedLbl: Label 'No video file has been uploaded. Please upload an MP4 file first.';
        VideoUploadedLbl: Label 'Video file uploaded successfully. Click "Analyze Video" to start the AI analysis.';
        AnalysisCompletedLbl: Label 'Video analysis completed successfully. %1 steps identified.', Comment = '%1 = number of steps';
        ApiCallFailedLbl: Label 'API call failed with status %1: %2', Comment = '%1 = HTTP status code, %2 = reason phrase';
        InvalidResponseLbl: Label 'Invalid response received from the AI provider. Please check your settings.';
        NoApiKeyLbl: Label 'API Key is not configured. Please set up the Video Analysis Setup first.';
        NoEndpointLbl: Label 'Endpoint URL is not configured. Please set up the Video Analysis Setup first.';
        NoDeploymentNameLbl: Label 'Deployment Name / Model is not configured. Examples: gpt-4o (Azure/GitHub), gemini-1.5-flash (Google Gemini).';
        SceneChangeMarkerLbl: Label '[SCENE CHANGE:', Locked = true;
        ConnectionOkLbl: Label 'Connection to the AI provider was successful.';
        TestPromptLbl: Label 'Reply with only the word OK.', Locked = true;
        GitHubModelsEndpointTxt: Label 'https://models.inference.ai.azure.com', Locked = true;
        GeminiEndpointTxt: Label 'https://generativelanguage.googleapis.com', Locked = true;
        HtmlResponseErr: Label 'GitHub Enterprise SSO-redirect received instead of JSON. Your PAT is not SSO-authorized. Fix: Go to 9altitudes.ghe.com/settings/tokens, find your token, click Configure SSO and Authorize for 9altitudes. Also set Endpoint URL to: https://copilot-api.9altitudes.ghe.com';

    procedure AnalyzeVideo(var VideoAnalysis: Record NALVideoAnalysis)
    var
        Setup: Record NALVideoAnalysisSetup;
        Base64Video: Text;
        ResponseText: Text;
        LineCount: Integer;
    begin
        Setup.GetOrCreateSetup(Setup);
        ValidateSetup(Setup);

        VideoAnalysis.CalcFields(VideoData);
        if not VideoAnalysis.VideoData.HasValue() then
            Error(VideoNotUploadedLbl);

        ValidateVideoSize(VideoAnalysis, Setup);

        VideoAnalysis.Status := VideoAnalysis.Status::Processing;
        VideoAnalysis.ErrorMessage := '';
        VideoAnalysis.Modify(true);
        Commit();

        DeleteAnalysisLines(VideoAnalysis.EntryNo);

        Base64Video := GetVideoAsBase64(VideoAnalysis);
        ResponseText := CallAIProvider(Base64Video, Setup);

        LineCount := ParseAndStoreLines(VideoAnalysis.EntryNo, ResponseText);

        VideoAnalysis.Status := VideoAnalysis.Status::Completed;
        VideoAnalysis.AnalysisDate := CurrentDateTime();
        VideoAnalysis.Modify(true);

        Message(AnalysisCompletedLbl, LineCount);
    end;

    local procedure ValidateSetup(Setup: Record NALVideoAnalysisSetup)
    begin
        if Setup.ApiKey = '' then
            Error(NoApiKeyLbl);
        if (Setup.Provider = Setup.Provider::AzureOpenAI) and (Setup.EndpointUrl = '') then
            Error(NoEndpointLbl);
        if Setup.DeploymentName = '' then
            Error(NoDeploymentNameLbl);
    end;

    local procedure ValidateVideoSize(VideoAnalysis: Record NALVideoAnalysis; Setup: Record NALVideoAnalysisSetup)
    var
        SizeMB: Integer;
    begin
        SizeMB := VideoAnalysis.VideoSizeKB div 1024;
        if SizeMB > Setup.MaxVideoSizeMB then
            Error(VideoTooLargeLbl, SizeMB, Setup.MaxVideoSizeMB);
    end;

    local procedure GetVideoAsBase64(var VideoAnalysis: Record NALVideoAnalysis): Text
    var
        VideoInStream: InStream;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        VideoAnalysis.VideoData.CreateInStream(VideoInStream);
        exit(Base64Convert.ToBase64(VideoInStream));
    end;

    local procedure CallAIProvider(Base64Video: Text; Setup: Record NALVideoAnalysisSetup): Text
    var
        HttpClient: HttpClient;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        HttpContent: HttpContent;
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        RequestBody: Text;
        ResponseText: Text;
    begin
        RequestBody := BuildRequestBody(Base64Video, Setup);

        HttpContent.WriteFrom(RequestBody);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        HttpRequest.Method := 'POST';
        HttpRequest.SetRequestUri(BuildRequestUrl(Setup));
        HttpRequest.GetHeaders(RequestHeaders);
        AddAuthHeader(RequestHeaders, Setup);
        HttpRequest.Content := HttpContent;

        if not HttpClient.Send(HttpRequest, HttpResponse) then
            Error(ApiCallFailedLbl, 0, 'Connection failed');

        if not HttpResponse.IsSuccessStatusCode() then begin
            HttpResponse.Content.ReadAs(ResponseText);
            Error(ApiCallFailedLbl, HttpResponse.HttpStatusCode(), ResponseText);
        end;

        HttpResponse.Content.ReadAs(ResponseText);
        exit(ExtractContentFromResponse(ResponseText, Setup));
    end;

    local procedure AddAuthHeader(var RequestHeaders: HttpHeaders; Setup: Record NALVideoAnalysisSetup)
    begin
        case Setup.Provider of
            Setup.Provider::GitHubModels:
                RequestHeaders.Add('Authorization', 'Bearer ' + Setup.ApiKey);
            Setup.Provider::GoogleGemini:
                RequestHeaders.Add('x-goog-api-key', Setup.ApiKey);
            else
                RequestHeaders.Add('api-key', Setup.ApiKey);
        end;
    end;

    local procedure BuildRequestUrl(Setup: Record NALVideoAnalysisSetup): Text
    var
        BaseUrl: Text;
    begin
        case Setup.Provider of
            Setup.Provider::GitHubModels:
                begin
                    BaseUrl := Setup.EndpointUrl;
                    if BaseUrl = '' then
                        BaseUrl := GitHubModelsEndpointTxt;
                    if BaseUrl.EndsWith('/') then
                        BaseUrl := CopyStr(BaseUrl, 1, StrLen(BaseUrl) - 1);
                    exit(BaseUrl + '/chat/completions');
                end;
            Setup.Provider::GoogleGemini:
                begin
                    BaseUrl := Setup.EndpointUrl;
                    if BaseUrl = '' then
                        BaseUrl := GeminiEndpointTxt;
                    if BaseUrl.EndsWith('/') then
                        BaseUrl := CopyStr(BaseUrl, 1, StrLen(BaseUrl) - 1);
                    exit(BaseUrl + '/v1/models/' + Setup.DeploymentName + ':generateContent');
                end;
            else begin
                BaseUrl := Setup.EndpointUrl;
                if BaseUrl.EndsWith('/') then
                    BaseUrl := CopyStr(BaseUrl, 1, StrLen(BaseUrl) - 1);
                exit(BaseUrl + '/openai/deployments/' + Setup.DeploymentName + '/chat/completions?api-version=' + Setup.ApiVersion);
            end;
        end;
    end;

    local procedure BuildRequestBody(Base64Video: Text; Setup: Record NALVideoAnalysisSetup): Text
    begin
        if Setup.Provider = Setup.Provider::GoogleGemini then
            exit(BuildGeminiRequestBody(Base64Video, Setup));
        exit(BuildOpenAIRequestBody(Base64Video, Setup));
    end;

    local procedure BuildGeminiRequestBody(Base64Video: Text; Setup: Record NALVideoAnalysisSetup): Text
    var
        JsonBody: JsonObject;
        ContentsArray: JsonArray;
        ContentObj: JsonObject;
        PartsArray: JsonArray;
        TextPart: JsonObject;
        VideoPart: JsonObject;
        InlineData: JsonObject;
        SystemInstruction: JsonObject;
        SystemParts: JsonArray;
        SystemTextPart: JsonObject;
        GenerationConfig: JsonObject;
        BodyText: Text;
    begin
        SystemTextPart.Add('text', Setup.GetSystemPromptText());
        SystemParts.Add(SystemTextPart);
        SystemInstruction.Add('parts', SystemParts);

        TextPart.Add('text', 'Please analyze this Business Central screen recording and provide a detailed step-by-step description in Danish. Mark each scene change with [SCENE CHANGE: HH:MM:SS].');

        InlineData.Add('mime_type', 'video/mp4');
        InlineData.Add('data', Base64Video);
        VideoPart.Add('inline_data', InlineData);

        PartsArray.Add(TextPart);
        PartsArray.Add(VideoPart);
        ContentObj.Add('parts', PartsArray);
        ContentsArray.Add(ContentObj);

        GenerationConfig.Add('maxOutputTokens', Setup.MaxTokens);
        GenerationConfig.Add('temperature', 0.3);

        JsonBody.Add('systemInstruction', SystemInstruction);
        JsonBody.Add('contents', ContentsArray);
        JsonBody.Add('generationConfig', GenerationConfig);

        JsonBody.WriteTo(BodyText);
        exit(BodyText);
    end;

    local procedure BuildOpenAIRequestBody(Base64Video: Text; Setup: Record NALVideoAnalysisSetup): Text
    var
        JsonBody: JsonObject;
        MessagesArray: JsonArray;
        SystemMessage: JsonObject;
        UserMessage: JsonObject;
        UserContentArray: JsonArray;
        TextContent: JsonObject;
        VideoContent: JsonObject;
        VideoUrlObj: JsonObject;
        BodyText: Text;
    begin
        SystemMessage.Add('role', 'system');
        SystemMessage.Add('content', Setup.GetSystemPromptText());

        TextContent.Add('type', 'text');
        TextContent.Add('text', 'Please analyze this Business Central screen recording and provide a detailed step-by-step description in Danish of what is happening. Mark each scene change with [SCENE CHANGE: HH:MM:SS].');

        VideoUrlObj.Add('url', 'data:video/mp4;base64,' + Base64Video);
        VideoContent.Add('type', 'video_url');
        VideoContent.Add('video_url', VideoUrlObj);

        UserContentArray.Add(TextContent);
        UserContentArray.Add(VideoContent);

        UserMessage.Add('role', 'user');
        UserMessage.Add('content', UserContentArray);

        MessagesArray.Add(SystemMessage);
        MessagesArray.Add(UserMessage);

        JsonBody.Add('messages', MessagesArray);
        JsonBody.Add('max_tokens', Setup.MaxTokens);
        JsonBody.Add('temperature', 0.3);
        // GitHub Models requires model name in body; Azure OpenAI uses it in the URL
        if Setup.Provider = Setup.Provider::GitHubModels then
            JsonBody.Add('model', Setup.DeploymentName);

        JsonBody.WriteTo(BodyText);
        exit(BodyText);
    end;

    local procedure ExtractContentFromResponse(ResponseJson: Text; Setup: Record NALVideoAnalysisSetup): Text
    var
        JsonObj: JsonObject;
        ChoicesToken: JsonToken;
        ChoiceToken: JsonToken;
        MessageToken: JsonToken;
        ContentToken: JsonToken;
        UsageToken: JsonToken;
        PromptTokensToken: JsonToken;
        CompletionTokensToken: JsonToken;
        ContentText: Text;
    begin
        // Detect HTML SSO redirect - response may have leading whitespace before the HTML tag
        if ResponseJson.Contains('<!DOCTYPE') or ResponseJson.Contains('<html') then
            Error(HtmlResponseErr);

        if not JsonObj.ReadFrom(ResponseJson) then
            Error(InvalidResponseLbl);

        // Show actual API error message if present
        if JsonObj.Get('error', ChoicesToken) then
            Error('API Error: %1', ExtractApiErrorMessage(ChoicesToken));

        // Gemini returns 'candidates', OpenAI returns 'choices'
        if Setup.Provider = Setup.Provider::GoogleGemini then
            exit(ExtractGeminiContent(JsonObj));

        if not JsonObj.Get('choices', ChoicesToken) then
            Error(InvalidResponseLbl + '\n\nResponse: ' + CopyStr(ResponseJson, 1, 500));

        if not ChoicesToken.AsArray().Get(0, ChoiceToken) then
            Error(InvalidResponseLbl);

        if not ChoiceToken.AsObject().Get('message', MessageToken) then
            Error(InvalidResponseLbl);

        if not MessageToken.AsObject().Get('content', ContentToken) then
            Error(InvalidResponseLbl);

        ContentText := ContentToken.AsValue().AsText();
        exit(ContentText);
    end;

    local procedure ExtractGeminiContent(JsonObj: JsonObject): Text
    var
        CandidatesToken: JsonToken;
        CandidateToken: JsonToken;
        ContentToken: JsonToken;
        PartsToken: JsonToken;
        PartToken: JsonToken;
        TextToken: JsonToken;
    begin
        if not JsonObj.Get('candidates', CandidatesToken) then
            Error(InvalidResponseLbl);
        if not CandidatesToken.AsArray().Get(0, CandidateToken) then
            Error(InvalidResponseLbl);
        if not CandidateToken.AsObject().Get('content', ContentToken) then
            Error(InvalidResponseLbl);
        if not ContentToken.AsObject().Get('parts', PartsToken) then
            Error(InvalidResponseLbl);
        if not PartsToken.AsArray().Get(0, PartToken) then
            Error(InvalidResponseLbl);
        if not PartToken.AsObject().Get('text', TextToken) then
            Error(InvalidResponseLbl);
        exit(TextToken.AsValue().AsText());
    end;

    local procedure ExtractApiErrorMessage(ErrorToken: JsonToken): Text
    var
        ErrorObj: JsonObject;
        MessageToken: JsonToken;
    begin
        ErrorObj := ErrorToken.AsObject();
        if ErrorObj.Get('message', MessageToken) then
            exit(MessageToken.AsValue().AsText());
        exit(Format(ErrorToken));
    end;

    local procedure ParseAndStoreLines(EntryNo: Integer; ResponseText: Text): Integer
    var
        VideoAnalysisLine: Record NALVideoAnalysisLine;
        Lines: List of [Text];
        LineText: Text;
        LineNo: Integer;
        Timestamp: Text;
    begin
        Lines := SplitIntoLines(ResponseText);
        LineNo := 10000;

        foreach LineText in Lines do begin
            LineText := LineText.Trim();
            if LineText <> '' then begin
                VideoAnalysisLine.Init();
                VideoAnalysisLine.EntryNo := EntryNo;
                VideoAnalysisLine.LineNo := LineNo;

                if LineText.StartsWith(SceneChangeMarkerLbl) then begin
                    VideoAnalysisLine.LineType := VideoAnalysisLine.LineType::SceneChange;
                    Timestamp := ExtractTimestamp(LineText);
                    VideoAnalysisLine.SequenceTime := CopyStr(Timestamp, 1, MaxStrLen(VideoAnalysisLine.SequenceTime));
                    VideoAnalysisLine.Description := CopyStr(LineText, 1, MaxStrLen(VideoAnalysisLine.Description));
                end else begin
                    VideoAnalysisLine.LineType := VideoAnalysisLine.LineType::Text;
                    VideoAnalysisLine.Description := CopyStr(LineText, 1, MaxStrLen(VideoAnalysisLine.Description));
                end;

                VideoAnalysisLine.Insert(true);
                LineNo += 10000;
            end;
        end;

        exit(LineNo div 10000 - 1);
    end;

    local procedure SplitIntoLines(InputText: Text): List of [Text]
    var
        ResultList: List of [Text];
        CurrentLine: Text;
        Position: Integer;
        CurrentChar: Char;
        CR: Char;
        LF: Char;
    begin
        CR := 13;
        LF := 10;
        CurrentLine := '';

        for Position := 1 to StrLen(InputText) do begin
            CurrentChar := InputText[Position];
            if (CurrentChar = LF) then begin
                ResultList.Add(CurrentLine);
                CurrentLine := '';
            end else begin
                if CurrentChar <> CR then
                    CurrentLine += Format(CurrentChar);
            end;
        end;
        if CurrentLine <> '' then
            ResultList.Add(CurrentLine);

        exit(ResultList);
    end;

    local procedure ExtractTimestamp(SceneChangeLine: Text): Text
    var
        StartPos: Integer;
        EndPos: Integer;
    begin
        // Extract HH:MM:SS from "[SCENE CHANGE: HH:MM:SS]"
        StartPos := StrPos(SceneChangeLine, ': ');
        if StartPos = 0 then
            exit('');
        StartPos += 2;
        EndPos := StrPos(SceneChangeLine, ']');
        if EndPos = 0 then
            exit(CopyStr(SceneChangeLine, StartPos));
        exit(CopyStr(SceneChangeLine, StartPos, EndPos - StartPos));
    end;

    local procedure DeleteAnalysisLines(EntryNo: Integer)
    var
        VideoAnalysisLine: Record NALVideoAnalysisLine;
    begin
        VideoAnalysisLine.SetRange(EntryNo, EntryNo);
        VideoAnalysisLine.DeleteAll(true);
    end;

    procedure ImportVideoFile(var VideoAnalysis: Record NALVideoAnalysis)
    var
        VideoInStream: InStream;
        FileName: Text;
        VideoOutStream: OutStream;
    begin
        if not UploadIntoStream('Select MP4 video file', '', 'MP4 Files (*.mp4)|*.mp4|All Files (*.*)|*.*', FileName, VideoInStream) then
            exit;

        VideoAnalysis.FileName := CopyStr(FileName, 1, MaxStrLen(VideoAnalysis.FileName));
        if VideoAnalysis.Description = '' then
            VideoAnalysis.Description := CopyStr(FileName, 1, MaxStrLen(VideoAnalysis.Description));

        // Write BLOB before saving - do NOT call CalcFields here as it overwrites in-memory BLOB with empty DB version
        VideoAnalysis.VideoData.CreateOutStream(VideoOutStream);
        CopyStream(VideoOutStream, VideoInStream);

        if VideoAnalysis.EntryNo = 0 then
            VideoAnalysis.Insert(true)
        else
            VideoAnalysis.Modify(true);

        // CalcFields after save to read actual size from DB
        VideoAnalysis.CalcFields(VideoData);
        VideoAnalysis.VideoSizeKB := VideoAnalysis.VideoData.Length() div 1024;
        VideoAnalysis.Modify(true);

        Message(VideoUploadedLbl);
    end;

    procedure ExportToHTML(var VideoAnalysis: Record NALVideoAnalysis): Text
    var
        VideoAnalysisLine: Record NALVideoAnalysisLine;
        HtmlContent: Text;
        LineClass: Text;
    begin
        HtmlContent := '<!DOCTYPE html><html lang="da"><head><meta charset="UTF-8"><title>' + VideoAnalysis.Description + '</title>';
        HtmlContent += '<style>';
        HtmlContent += 'body { font-family: Segoe UI, Arial, sans-serif; max-width: 900px; margin: 40px auto; padding: 20px; color: #333; }';
        HtmlContent += 'h1 { color: #0078d4; border-bottom: 2px solid #0078d4; padding-bottom: 10px; }';
        HtmlContent += '.meta { color: #666; font-size: 0.9em; margin-bottom: 30px; }';
        HtmlContent += '.step { margin: 15px 0; padding: 12px 15px; background: #f8f9fa; border-left: 4px solid #0078d4; border-radius: 4px; }';
        HtmlContent += '.scene-change { margin: 20px 0; padding: 10px 15px; background: #fff3cd; border-left: 4px solid #ffc107; border-radius: 4px; font-weight: bold; color: #856404; }';
        HtmlContent += '.timestamp { font-size: 0.8em; color: #666; margin-left: 8px; }';
        HtmlContent += '</style></head><body>';

        HtmlContent += '<h1>&#127909; BC Analyse: ' + VideoAnalysis.Description + '</h1>';
        HtmlContent += '<div class="meta">';
        HtmlContent += '<strong>Fil:</strong> ' + VideoAnalysis.FileName + ' &nbsp;|&nbsp; ';
        HtmlContent += '<strong>Analyseret:</strong> ' + Format(VideoAnalysis.AnalysisDate) + ' &nbsp;|&nbsp; ';
        HtmlContent += '<strong>St&oslash;rrelse:</strong> ' + Format(VideoAnalysis.VideoSizeKB div 1024) + ' MB';
        HtmlContent += '</div>';

        VideoAnalysisLine.SetRange(EntryNo, VideoAnalysis.EntryNo);
        VideoAnalysisLine.SetCurrentKey(EntryNo, LineNo);
        if VideoAnalysisLine.FindSet() then
            repeat
                case VideoAnalysisLine.LineType of
                    VideoAnalysisLine.LineType::SceneChange:
                        begin
                            HtmlContent += '<div class="scene-change">&#128247; Scene change';
                            if VideoAnalysisLine.SequenceTime <> '' then
                                HtmlContent += '<span class="timestamp">@ ' + VideoAnalysisLine.SequenceTime + '</span>';
                            HtmlContent += '</div>';
                        end;
                    VideoAnalysisLine.LineType::Text:
                        begin
                            HtmlContent += '<div class="step">' + VideoAnalysisLine.Description + '</div>';
                        end;
                end;
            until VideoAnalysisLine.Next() = 0;

        HtmlContent += '</body></html>';
        exit(HtmlContent);
    end;

    procedure DownloadHTMLReport(var VideoAnalysis: Record NALVideoAnalysis)
    var
        HtmlContent: Text;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        DownloadFileName: Text;
    begin
        HtmlContent := ExportToHTML(VideoAnalysis);
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(HtmlContent);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        DownloadFileName := VideoAnalysis.Description + '.html';
        DownloadFromStream(InStr, 'Save HTML Report', '', 'HTML Files (*.html)|*.html', DownloadFileName);
    end;

    procedure TestConnection(var Setup: Record NALVideoAnalysisSetup)
    var
        HttpClient: HttpClient;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        HttpContent: HttpContent;
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        RequestBody: Text;
        ResponseText: Text;
        JsonBody: JsonObject;
        MessagesArray: JsonArray;
        UserMessage: JsonObject;
    begin
        ValidateSetup(Setup);

        if Setup.Provider = Setup.Provider::GoogleGemini then begin
            // Gemini test request format
            RequestBody := '{"contents":[{"parts":[{"text":"' + TestPromptLbl + '"}]}]}';
        end else begin
            UserMessage.Add('role', 'user');
            UserMessage.Add('content', TestPromptLbl);
            MessagesArray.Add(UserMessage);
            JsonBody.Add('messages', MessagesArray);
            JsonBody.Add('max_tokens', 10);
            if Setup.Provider = Setup.Provider::GitHubModels then
                JsonBody.Add('model', Setup.DeploymentName);
            JsonBody.WriteTo(RequestBody);
        end;

        HttpContent.WriteFrom(RequestBody);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        HttpRequest.Method := 'POST';
        HttpRequest.SetRequestUri(BuildRequestUrl(Setup));
        HttpRequest.GetHeaders(RequestHeaders);
        AddAuthHeader(RequestHeaders, Setup);
        HttpRequest.Content := HttpContent;

        if not HttpClient.Send(HttpRequest, HttpResponse) then
            Error(ApiCallFailedLbl, 0, 'Connection failed. Check endpoint URL.');

        if not HttpResponse.IsSuccessStatusCode() then begin
            HttpResponse.Content.ReadAs(ResponseText);
            Error(ApiCallFailedLbl, HttpResponse.HttpStatusCode(), ResponseText);
        end;

        Message(ConnectionOkLbl);
    end;
}
