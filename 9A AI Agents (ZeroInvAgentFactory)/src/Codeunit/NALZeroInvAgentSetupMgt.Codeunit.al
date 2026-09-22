// Helper logic shared between the agent factory, metadata provider and install codeunit.
codeunit 50110 NALZeroInvAgentSetupMgt
{
    Access = Internal;

    procedure GetInitials(): Text[4]
    begin
        exit(AgentInitialsLbl);
    end;

    procedure GetSetupPageId(): Integer
    begin
        exit(Page::NALZeroInvAgentSetup);
    end;

    procedure GetSummaryPageId(): Integer
    begin
        exit(Page::NALZeroInvAgentKPI);
    end;

    /// <summary>
    /// Gets the instructions from resources.
    /// </summary>
    [NonDebuggable]
    procedure GetInstructions(): SecretText
    var
        Instructions: Text;
    begin
        Instructions := NavApp.GetResourceAsText('Instructions/NALZeroInvAgentInstructionsV1.txt');
        exit(Instructions);
    end;

    procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        Agent.PopulateDefaultProfile(DefaultProfileTok, CurrentModuleInfo.Id, TempAllProfile);
    end;

    procedure GetDefaultAccessControls(var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        Clear(TempAccessControlBuffer);
        TempAccessControlBuffer."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(TempAccessControlBuffer."Company Name"));
        TempAccessControlBuffer.Scope := TempAccessControlBuffer.Scope::System;
        TempAccessControlBuffer."App ID" := CurrentModuleInfo.Id;
        TempAccessControlBuffer."Role ID" := DefaultPermissionSetTok;
        TempAccessControlBuffer.Insert();
    end;

    procedure GetAgentMetadataProvider(): Enum "Agent Metadata Provider"
    begin
        exit(Enum::"Agent Metadata Provider"::"NAL Zero Inventory Agent");
    end;

    procedure GetAgentUserName(): Code[50]
    begin
        exit(CopyStr(AgentNameLbl + ' - ' + CompanyName(), 1, 50));
    end;

    procedure GetDefaultDisplayName(): Text[80]
    begin
        exit(DefaultDisplayNameLbl);
    end;

    procedure GetAgentSummary(): Text
    begin
        exit(AgentSummaryLbl);
    end;

    procedure InitializeSetupRecord(var TempNALZeroInvAgentSetup: Record NALZeroInvAgentSetup temporary)
    begin
        if TempNALZeroInvAgentSetup.IsEmpty() then
            TempNALZeroInvAgentSetup.Insert();
    end;

    procedure SaveSetupRecord(var TempNALZeroInvAgentSetup: Record NALZeroInvAgentSetup temporary; var AgentSetupBuffer: Record "Agent Setup Buffer")
    var
        NALZeroInvAgentSetupRecord: Record NALZeroInvAgentSetup;
        AgentSetup: Codeunit "Agent Setup";
        IsNewAgent: Boolean;
    begin
        IsNewAgent := IsNullGuid(AgentSetupBuffer."User Security ID");

        if AgentSetup.GetChangesMade(AgentSetupBuffer) then begin
            TempNALZeroInvAgentSetup."User Security ID" := AgentSetup.SaveChanges(AgentSetupBuffer);

            if IsNewAgent then
                Agent.SetInstructions(TempNALZeroInvAgentSetup."User Security ID", GetInstructions());

            if not NALZeroInvAgentSetupRecord.Get(TempNALZeroInvAgentSetup."User Security ID") then begin
                NALZeroInvAgentSetupRecord."User Security ID" := TempNALZeroInvAgentSetup."User Security ID";
                NALZeroInvAgentSetupRecord.Insert();
            end;
        end;
    end;

    var
        Agent: Codeunit Agent;
        DefaultPermissionSetTok: Label 'NALZEROINVAGENT', Locked = true;
        DefaultProfileTok: Label 'NALZEROINVAGENTPROFILE', Locked = true;
        AgentInitialsLbl: Label 'ZIA', MaxLength = 4;
        AgentNameLbl: Label 'NAL Zero Inventory Agent';
        DefaultDisplayNameLbl: Label 'NAL Zero Inventory Agent';
        AgentSummaryLbl: Label 'Reviews inventory items and blocks the ones with 0 on-hand quantity.';
}
