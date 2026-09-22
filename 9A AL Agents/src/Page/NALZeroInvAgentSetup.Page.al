// This page serves as the setup page for the NAL Zero Inventory Agent.
// The Agent Setup Part handles common agent configuration (name, state, access control).
#pragma warning disable AL0906 // ConfigurationDialog page type is required for agent setup and is currently in public preview
page 50104 NALZeroInvAgentSetup
{
    PageType = ConfigurationDialog;
    Extensible = false;
    ApplicationArea = All;
    IsPreview = true;
    Caption = 'Set up NAL Zero Inventory Agent';
    InstructionalText = 'Reviews inventory items and blocks the ones with 0 on-hand quantity.';
    AdditionalSearchTerms = 'NAL Zero Inventory Agent, Agent';
    SourceTable = NALZeroInvAgentSetup;
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
        NALZeroInvAgentSetupMgt: Codeunit NALZeroInvAgentSetupMgt;
        UserSecurityIDFilter: Text;
        UserSecurityID: Guid;
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"NAL Zero Inventory Agent Capability") then
            Error(NALAgentIsNotEnabledInCopilotCapabilitiesErr);

        UserSecurityIDFilter := Rec.GetFilter("User Security ID");
        if not Evaluate(UserSecurityID, UserSecurityIDFilter) then
            Clear(UserSecurityID);

        Rec."User Security ID" := UserSecurityID;

        CurrPage.AgentSetupPart.Page.Initialize(
            UserSecurityID,
            NALZeroInvAgentSetupMgt.GetAgentMetadataProvider(),
            NALZeroInvAgentSetupMgt.GetAgentUserName(),
            NALZeroInvAgentSetupMgt.GetDefaultDisplayName(),
            NALZeroInvAgentSetupMgt.GetAgentSummary());

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
        NALZeroInvAgentSetupMgt: Codeunit NALZeroInvAgentSetupMgt;
    begin
        if CloseAction = CloseAction::Cancel then
            exit(true);

        CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(AgentSetupBuffer);
        NALZeroInvAgentSetupMgt.SaveSetupRecord(Rec, AgentSetupBuffer);
        exit(true);
    end;

    local procedure InitializePage()
    var
        NALZeroInvAgentSetupMgt: Codeunit NALZeroInvAgentSetupMgt;
    begin
        CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(AgentSetupBuffer);
        NALZeroInvAgentSetupMgt.InitializeSetupRecord(Rec);

        AgentDisplayName := AgentSetupBuffer."Display Name";
        IsUpdated := IsUpdated or CurrPage.AgentSetupPart.Page.GetChangesMade();
    end;

    var
        AgentSetupBuffer: Record "Agent Setup Buffer";
        AzureOpenAI: Codeunit "Azure OpenAI";
        IsUpdated: Boolean;
        NALAgentIsNotEnabledInCopilotCapabilitiesErr: Label 'The NAL Zero Inventory Agent capability is not enabled in Copilot capabilities.\\Please enable the capability before setting up the agent.';
        AgentDisplayName: Text[80];
}
