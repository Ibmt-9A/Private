// Re-pushes the latest instructions to existing agent instances whenever the app is upgraded (republished),
// since the platform only picks up instruction changes when SetInstructions is explicitly called again.
codeunit 50106 NALSOAgentUpgrade
{
    Subtype = Upgrade;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnUpgradePerDatabase()
    var
        NALSOAgentSetupMgt: Codeunit NALSOAgentSetupMgt;
    begin
        NALSOAgentSetupMgt.RefreshInstructionsForAllAgents();
    end;
}
