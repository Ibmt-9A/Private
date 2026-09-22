// Registers the Copilot capability and pushes the latest instructions to existing agent instances on install.
codeunit 50104 NALSOAgentInstall
{
    Subtype = Install;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnInstallAppPerDatabase()
    var
        NALSOAgentSetup: Record NALSOAgentSetup;
    begin
        RegisterCapability();

        if not NALSOAgentSetup.FindSet() then
            exit;

        repeat
            InstallAgentInstructions(NALSOAgentSetup);
        until NALSOAgentSetup.Next() = 0;
    end;

    local procedure InstallAgentInstructions(var NALSOAgentSetup: Record NALSOAgentSetup)
    var
        Agent: Codeunit Agent;
        NALSOAgentSetupMgt: Codeunit NALSOAgentSetupMgt;
    begin
        Agent.SetInstructions(NALSOAgentSetup."User Security ID", NALSOAgentSetupMgt.GetInstructions());
    end;

    local procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        LearnMoreUrlTxt: Label 'https://learn.microsoft.com/dynamics365/business-central/dev-itpro/ai/ai-agent-sdk-overview', Locked = true;
    begin
        if CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"NAL Sales Order Agent Capability") then
            exit;

        CopilotCapability.RegisterCapability(
            Enum::"Copilot Capability"::"NAL Sales Order Agent Capability",
            Enum::"Copilot Availability"::Preview,
            "Copilot Billing Type"::"Microsoft Billed",
            LearnMoreUrlTxt);
    end;
}
