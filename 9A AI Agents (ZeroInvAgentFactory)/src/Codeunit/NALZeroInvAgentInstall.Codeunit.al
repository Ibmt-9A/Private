// Registers the Copilot capability and pushes the latest instructions to existing agent instances on install.
codeunit 50111 NALZeroInvAgentInstall
{
    Subtype = Install;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnInstallAppPerDatabase()
    var
        NALZeroInvAgentSetup: Record NALZeroInvAgentSetup;
    begin
        RegisterCapability();

        if not NALZeroInvAgentSetup.FindSet() then
            exit;

        repeat
            InstallAgentInstructions(NALZeroInvAgentSetup);
        until NALZeroInvAgentSetup.Next() = 0;
    end;

    local procedure InstallAgentInstructions(var NALZeroInvAgentSetup: Record NALZeroInvAgentSetup)
    var
        Agent: Codeunit Agent;
        NALZeroInvAgentSetupMgt: Codeunit NALZeroInvAgentSetupMgt;
    begin
        Agent.SetInstructions(NALZeroInvAgentSetup."User Security ID", NALZeroInvAgentSetupMgt.GetInstructions());
    end;

    local procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        LearnMoreUrlTxt: Label 'https://learn.microsoft.com/dynamics365/business-central/dev-itpro/ai/ai-agent-sdk-overview', Locked = true;
    begin
        if CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"NAL Zero Inventory Agent Capability") then
            exit;

        CopilotCapability.RegisterCapability(
            Enum::"Copilot Capability"::"NAL Zero Inventory Agent Capability",
            Enum::"Copilot Availability"::Preview,
            "Copilot Billing Type"::"Microsoft Billed",
            LearnMoreUrlTxt);
    end;
}
