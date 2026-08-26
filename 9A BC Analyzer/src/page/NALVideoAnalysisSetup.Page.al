page 51000 NALVideoAnalysisSetup
{
    Caption = 'Video Analysis Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = NALVideoAnalysisSetup;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(AzureOpenAI)
            {
                Caption = 'AI Provider Connection';

                field(Provider; Rec.Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Select the AI provider. Azure OpenAI requires your own Azure resource. GitHub Models uses your GitHub account.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(EndpointUrl; Rec.EndpointUrl)
                {
                    ApplicationArea = All;
                    ToolTip = 'Azure OpenAI: https://NAVN.openai.azure.com  |  GitHub Models: lad feltet stå tomt for at bruge https://models.inference.ai.azure.com automatisk. OBS: ghe.FIRMA.com er GitHub Enterprise og virker IKKE her.';
                }
                field(DefaultEndpointHint; GetDefaultEndpointHint())
                {
                    ApplicationArea = All;
                    Caption = '';
                    Editable = false;
                    Visible = IsGitHubModels or IsGemini;
                    Style = StrongAccent;

                    trigger OnDrillDown()
                    begin
                        if IsGemini then
                            Rec.EndpointUrl := GeminiEndpointTxt
                        else
                            Rec.EndpointUrl := GitHubModelsEndpointTxt;
                        Rec.Modify(true);
                        CurrPage.Update(false);
                    end;
                }
                field(ApiKey; Rec.ApiKey)
                {
                    ApplicationArea = All;
                    ToolTip = 'Azure OpenAI: din Azure API-nøgle.  |  GitHub Models: dit GitHub Personal Access Token (PAT).';
                }
                field(DeploymentName; Rec.DeploymentName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Azure OpenAI: deployment-navn.  |  GitHub Models: gpt-4o.  |  Google Gemini: gemini-2.0-flash (anbefalet, gratis) eller gemini-2.5-pro.';
                }
                field(ApiVersion; Rec.ApiVersion)
                {
                    ApplicationArea = All;
                    Visible = IsAzureOpenAI;
                    ToolTip = 'Azure OpenAI API-version. Brug 2025-01-01-preview eller nyere for video-support.';
                }
            }
            group(Settings)
            {
                Caption = 'Analysis Settings';

                field(MaxTokens; Rec.MaxTokens)
                {
                    ApplicationArea = All;
                    ToolTip = 'Maximum number of tokens in the AI response. Higher values allow more detailed analysis.';
                }
                field(MaxVideoSizeMB; Rec.MaxVideoSizeMB)
                {
                    ApplicationArea = All;
                    ToolTip = 'Maximum allowed video file size in MB. Larger videos require more API resources.';
                }
            }
            group(SystemPromptGrp)
            {
                Caption = 'System Prompt';

                field(SystemPromptDisplay; SystemPromptText)
                {
                    ApplicationArea = All;
                    Caption = 'System Prompt';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    ToolTip = 'Tilpas de instruktioner der sendes til AI-udbyderen. Lad feltet være tomt for at bruge standard-prompten.';

                    trigger OnValidate()
                    begin
                        Rec.SetSystemPromptText(SystemPromptText);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestConnection)
            {
                Caption = 'Test Connection';
                ApplicationArea = All;
                Image = TestDatabase;
                ToolTip = 'Verify the Azure OpenAI connection settings by sending a test request.';

                trigger OnAction()
                var
                    VideoAnalysisMgt: Codeunit NALVideoAnalysisMgt;
                begin
                    VideoAnalysisMgt.TestConnection(Rec);
                end;
            }
        }
        area(Promoted)
        {
            actionref(TestConnection_Promoted; TestConnection) { }
        }
    }

    var
        SystemPromptText: Text;
        IsGitHubModels: Boolean;
        IsAzureOpenAI: Boolean;
        IsGemini: Boolean;
        GitHubModelsEndpointTxt: Label 'https://models.inference.ai.azure.com', Locked = true;
        GeminiEndpointTxt: Label 'https://generativelanguage.googleapis.com', Locked = true;

    local procedure UpdateProviderFlags()
    begin
        IsGitHubModels := Rec.Provider = Rec.Provider::GitHubModels;
        IsAzureOpenAI := Rec.Provider = Rec.Provider::AzureOpenAI;
        IsGemini := Rec.Provider = Rec.Provider::GoogleGemini;
    end;

    local procedure GetDefaultEndpointHint(): Text
    var
        UseGitHubLbl: Label '↩ Klik for at bruge standard GitHub Models endpoint';
        UseGeminiLbl: Label '↩ Klik for at bruge standard Google Gemini endpoint';
        AlreadySetLbl: Label '✓ Endpoint er sat korrekt';
    begin
        if IsGemini then begin
            if Rec.EndpointUrl = GeminiEndpointTxt then
                exit(AlreadySetLbl);
            exit(UseGeminiLbl);
        end;
        if Rec.EndpointUrl = GitHubModelsEndpointTxt then
            exit(AlreadySetLbl);
        exit(UseGitHubLbl);
    end;

    trigger OnOpenPage()
    begin
        Rec.GetOrCreateSetup(Rec);
        SystemPromptText := Rec.GetSystemPromptText();
        UpdateProviderFlags();
    end;

    trigger OnAfterGetRecord()
    begin
        SystemPromptText := Rec.GetSystemPromptText();
        UpdateProviderFlags();
    end;
}
