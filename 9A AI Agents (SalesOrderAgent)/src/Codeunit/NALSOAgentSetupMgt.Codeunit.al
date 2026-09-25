// Helper logic shared between the agent factory, metadata provider and install codeunit.
codeunit 50103 NALSOAgentSetupMgt
{
    Access = Internal;

    procedure GetInitials(): Text[4]
    begin
        exit(AgentInitialsLbl);
    end;

    procedure GetSetupPageId(): Integer
    begin
        exit(Page::NALSOAgentSetup);
    end;

    procedure GetSummaryPageId(): Integer
    begin
        exit(Page::NALSOAgentKPI);
    end;

    /// <summary>
    /// Gets the instructions from resources.
    /// </summary>
    [NonDebuggable]
    procedure GetInstructions(): SecretText
    var
        Instructions: Text;
    begin
        Instructions := NavApp.GetResourceAsText('Instructions/NALSOAgentInstructionsV1.txt');
        exit(Instructions);
    end;

    /// <summary>
    /// Pushes the current instructions (from resources) to every existing agent instance.
    /// Must run on both install and upgrade, since instructions are only picked up by the platform when explicitly set.
    /// </summary>
    procedure RefreshInstructionsForAllAgents()
    var
        NALSOAgentSetup: Record NALSOAgentSetup;
        Agent: Codeunit Agent;
        Instructions: SecretText;
    begin
        if not NALSOAgentSetup.FindSet() then
            exit;

        Instructions := GetInstructions();
        repeat
            Agent.SetInstructions(NALSOAgentSetup."User Security ID", Instructions);
        until NALSOAgentSetup.Next() = 0;
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
        exit(Enum::"Agent Metadata Provider"::"NAL Sales Order Agent");
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

    procedure InitializeSetupRecord(var TempNALSOAgentSetup: Record NALSOAgentSetup temporary)
    begin
        if TempNALSOAgentSetup.IsEmpty() then
            TempNALSOAgentSetup.Insert();
    end;

    procedure SaveSetupRecord(var TempNALSOAgentSetup: Record NALSOAgentSetup temporary; var AgentSetupBuffer: Record "Agent Setup Buffer")
    var
        NALSOAgentSetupRecord: Record NALSOAgentSetup;
        AgentSetup: Codeunit "Agent Setup";
        IsNewAgent: Boolean;
    begin
        IsNewAgent := IsNullGuid(AgentSetupBuffer."User Security ID");

        if AgentSetup.GetChangesMade(AgentSetupBuffer) then begin
            TempNALSOAgentSetup."User Security ID" := AgentSetup.SaveChanges(AgentSetupBuffer);

            if IsNewAgent then
                Agent.SetInstructions(TempNALSOAgentSetup."User Security ID", GetInstructions());

            if not NALSOAgentSetupRecord.Get(TempNALSOAgentSetup."User Security ID") then begin
                NALSOAgentSetupRecord."User Security ID" := TempNALSOAgentSetup."User Security ID";
                NALSOAgentSetupRecord.Insert();
            end;
        end;
    end;

    var
        Agent: Codeunit Agent;
        DefaultPermissionSetTok: Label 'NALSOAGENT', Locked = true;
        DefaultProfileTok: Label 'NALSOAGENTPROFILE', Locked = true;
        AgentInitialsLbl: Label 'SOA', MaxLength = 4;
        AgentNameLbl: Label 'NAL Sales Order Agent';
        DefaultDisplayNameLbl: Label 'NAL Sales Order Agent';
        AgentSummaryLbl: Label 'Captures sales quote and order requests and creates the matching sales documents.';
}
