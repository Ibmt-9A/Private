table 51000 NALVideoAnalysisSetup
{
    Caption = 'Video Analysis Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; PrimaryKey; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; EndpointUrl; Text[250])
        {
            Caption = 'Endpoint URL';
            DataClassification = CustomerContent;
        }
        field(3; ApiKey; Text[250])
        {
            Caption = 'API Key';
            DataClassification = EndUserPseudonymousIdentifiers;
            ExtendedDatatype = Masked;
        }
        field(4; DeploymentName; Text[100])
        {
            Caption = 'Deployment Name';
            DataClassification = CustomerContent;
        }
        field(5; MaxTokens; Integer)
        {
            Caption = 'Max Tokens';
            DataClassification = SystemMetadata;
            InitValue = 4096;
            MinValue = 256;
            MaxValue = 16384;
        }
        field(6; ApiVersion; Text[50])
        {
            Caption = 'API Version';
            DataClassification = CustomerContent;
            InitValue = '2025-01-01-preview';
        }
        field(7; SystemPrompt; Blob)
        {
            Caption = 'System Prompt';
            DataClassification = CustomerContent;
        }
        field(8; MaxVideoSizeMB; Integer)
        {
            Caption = 'Max Video Size (MB)';
            DataClassification = SystemMetadata;
            InitValue = 50;
            MinValue = 1;
            MaxValue = 200;
        }
        field(9; Provider; Enum NALVideoAnalysisProvider)
        {
            Caption = 'AI Provider';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec.Provider = Rec.Provider::GitHubModels then begin
                    if Rec.EndpointUrl = '' then
                        Rec.EndpointUrl := GitHubModelsEndpointTxt;
                    if Rec.ApiVersion <> '' then
                        Rec.ApiVersion := '';
                end else begin
                    if Rec.Provider = Rec.Provider::GoogleGemini then begin
                        if Rec.EndpointUrl = '' then
                            Rec.EndpointUrl := 'https://generativelanguage.googleapis.com';
                        if Rec.ApiVersion <> '' then
                            Rec.ApiVersion := '';
                    end else begin
                        if Rec.EndpointUrl = GitHubModelsEndpointTxt then
                            Rec.EndpointUrl := '';
                        if Rec.ApiVersion = '' then
                            Rec.ApiVersion := '2025-01-01-preview';
                    end;
                end;
            end;
        }
    }

    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }

    var
        GitHubModelsEndpointTxt: Label 'https://models.inference.ai.azure.com', Locked = true;

    procedure GetSetup(var VideoAnalysisSetup: Record NALVideoAnalysisSetup)
    var
        SetupNotFoundErr: Label 'Video Analysis Setup not found. Please configure the setup first.';
    begin
        if not VideoAnalysisSetup.Get('') then
            Error(SetupNotFoundErr);
    end;

    procedure GetOrCreateSetup(var VideoAnalysisSetup: Record NALVideoAnalysisSetup)
    begin
        if not VideoAnalysisSetup.Get('') then begin
            VideoAnalysisSetup.Init();
            VideoAnalysisSetup.PrimaryKey := '';
            VideoAnalysisSetup.Insert(true);
        end;
    end;

    procedure GetSystemPromptText(): Text
    var
        TextInStream: InStream;
        PromptText: Text;
        DefaultPromptLbl: Label 'You are an expert at analyzing Microsoft Dynamics 365 Business Central screen recordings. Analyze the video and provide a detailed step-by-step description of what happens in Danish language. For each distinct screen change, describe: 1) Which page/module is shown, 2) What actions are performed, 3) What data is entered or viewed. Format your response as numbered steps. Mark each scene change with a line starting with [SCENE CHANGE: HH:MM:SS] where HH:MM:SS is the approximate timestamp. After the last step, add a section titled "Summary" with a brief overview of the entire session.', Locked = true;
    begin
        Rec.CalcFields(SystemPrompt);
        if Rec.SystemPrompt.HasValue() then begin
            Rec.SystemPrompt.CreateInStream(TextInStream, TextEncoding::UTF8);
            TextInStream.ReadText(PromptText);
        end;
        if PromptText = '' then
            PromptText := DefaultPromptLbl;
        exit(PromptText);
    end;

    procedure SetSystemPromptText(NewPromptText: Text)
    var
        TextOutStream: OutStream;
    begin
        Rec.SystemPrompt.CreateOutStream(TextOutStream, TextEncoding::UTF8);
        TextOutStream.WriteText(NewPromptText);
    end;
}
