// This page serves as the setup page for the NAL Sales Order Agent.
// The Agent Setup Part handles common agent configuration (name, state, access control).
#pragma warning disable AL0906 // ConfigurationDialog page type is required for agent setup and is currently in public preview
page 50100 NALSOAgentSetup
{
    PageType = ConfigurationDialog;
    Extensible = false;
    ApplicationArea = All;
    IsPreview = true;
    Caption = 'Set up NAL Sales Order Agent';
    InstructionalText = 'Captures sales quote and order requests and creates the matching sales documents.';
    AdditionalSearchTerms = 'NAL Sales Order Agent, Agent';
    SourceTable = NALSOAgentSetup;
    SourceTableTemporary = true;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            part(AgentSetupPart; "Agent Setup Part")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
            }

            group(AdditionalConfiguration)
            {
                Caption = 'Additional Configuration';
                InstructionalText = 'Update the agent display name.';

                field(DisplayName; AgentDisplayName)
                {
                    Caption = 'Display Name';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the display name of the agent.';

                    trigger OnValidate()
                    begin
                        AgentSetupBuffer.Validate("Display Name", AgentDisplayName);
                        AgentSetupBuffer.Modify(true);
                        IsUpdated := true;

                        CurrPage.AgentSetupPart.Page.SetAgentSetupBuffer(AgentSetupBuffer);
                        CurrPage.AgentSetupPart.Page.Update(false);
                    end;
                }
            }
        }
    }
    actions
    {
        area(SystemActions)
        {
            systemaction(OK)
            {
                Caption = 'Update';
                Enabled = IsUpdated;
                ToolTip = 'Apply the changes to the agent setup.';
            }

            systemaction(Cancel)
            {
                Caption = 'Cancel';
                ToolTip = 'Discards the changes and closes the setup page.';
            }
        }
    }

    trigger OnOpenPage()
    var
        NALSOAgentSetupMgt: Codeunit NALSOAgentSetupMgt;
        UserSecurityIDFilter: Text;
        UserSecurityID: Guid;
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"NAL Sales Order Agent Capability") then
            Error(NALAgentIsNotEnabledInCopilotCapabilitiesErr);

        UserSecurityIDFilter := Rec.GetFilter("User Security ID");
        if not Evaluate(UserSecurityID, UserSecurityIDFilter) then
            Clear(UserSecurityID);

        Rec."User Security ID" := UserSecurityID;

        CurrPage.AgentSetupPart.Page.Initialize(
            UserSecurityID,
            NALSOAgentSetupMgt.GetAgentMetadataProvider(),
            NALSOAgentSetupMgt.GetAgentUserName(),
            NALSOAgentSetupMgt.GetDefaultDisplayName(),
            NALSOAgentSetupMgt.GetAgentSummary());

        InitializePage();
        IsUpdated := CurrPage.AgentSetupPart.Page.GetChangesMade();
    end;

    trigger OnAfterGetRecord()
    begin
        InitializePage();
        IsUpdated := IsUpdated or CurrPage.AgentSetupPart.Page.GetChangesMade();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IsUpdated := IsUpdated or CurrPage.AgentSetupPart.Page.GetChangesMade();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IsUpdated := true;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NALSOAgentSetupMgt: Codeunit NALSOAgentSetupMgt;
    begin
        if CloseAction = CloseAction::Cancel then
            exit(true);

        CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(AgentSetupBuffer);
        NALSOAgentSetupMgt.SaveSetupRecord(Rec, AgentSetupBuffer);
        exit(true);
    end;

    local procedure InitializePage()
    var
        NALSOAgentSetupMgt: Codeunit NALSOAgentSetupMgt;
    begin
        CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(AgentSetupBuffer);
        NALSOAgentSetupMgt.InitializeSetupRecord(Rec);

        AgentDisplayName := AgentSetupBuffer."Display Name";
        IsUpdated := IsUpdated or CurrPage.AgentSetupPart.Page.GetChangesMade();
    end;

    var
        AgentSetupBuffer: Record "Agent Setup Buffer";
        AzureOpenAI: Codeunit "Azure OpenAI";
        IsUpdated: Boolean;
        NALAgentIsNotEnabledInCopilotCapabilitiesErr: Label 'The NAL Sales Order Agent capability is not enabled in Copilot capabilities.\\Please enable the capability before setting up the agent.';
        AgentDisplayName: Text[80];
}
