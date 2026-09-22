// Implements IAgentFactory: defines how new NAL Zero Inventory Agent instances are created.
codeunit 50107 NALZeroInvAgentFactory implements IAgentFactory
{
    Access = Internal;

    procedure GetDefaultInitials(): Text[4]
    begin
        exit(NALZeroInvAgentSetupMgt.GetInitials());
    end;

    procedure GetFirstTimeSetupPageId(): Integer
    begin
        exit(NALZeroInvAgentSetupMgt.GetSetupPageId());
    end;

    procedure ShowCanCreateAgent(): Boolean
    begin
        exit(true);
    end;

    procedure GetCopilotCapability(): Enum "Copilot Capability"
    begin
        exit(Enum::"Copilot Capability"::"NAL Zero Inventory Agent Capability");
    end;

    procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    begin
        NALZeroInvAgentSetupMgt.GetDefaultProfile(TempAllProfile);
    end;

    procedure GetDefaultAccessControls(var TempAccessControlTemplate: Record "Access Control Buffer" temporary)
    begin
        NALZeroInvAgentSetupMgt.GetDefaultAccessControls(TempAccessControlTemplate);
    end;

    var
        NALZeroInvAgentSetupMgt: Codeunit NALZeroInvAgentSetupMgt;
}
