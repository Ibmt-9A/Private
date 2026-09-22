// Implements IAgentFactory: defines how new NAL Sales Order Agent instances are created.
codeunit 50100 NALSOAgentFactory implements IAgentFactory
{
    Access = Internal;

    procedure GetDefaultInitials(): Text[4]
    begin
        exit(NALSOAgentSetupMgt.GetInitials());
    end;

    procedure GetFirstTimeSetupPageId(): Integer
    begin
        exit(NALSOAgentSetupMgt.GetSetupPageId());
    end;

    procedure ShowCanCreateAgent(): Boolean
    begin
        exit(true);
    end;

    procedure GetCopilotCapability(): Enum "Copilot Capability"
    begin
        exit(Enum::"Copilot Capability"::"NAL Sales Order Agent Capability");
    end;

    procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    begin
        NALSOAgentSetupMgt.GetDefaultProfile(TempAllProfile);
    end;

    procedure GetDefaultAccessControls(var TempAccessControlTemplate: Record "Access Control Buffer" temporary)
    begin
        NALSOAgentSetupMgt.GetDefaultAccessControls(TempAccessControlTemplate);
    end;

    var
        NALSOAgentSetupMgt: Codeunit NALSOAgentSetupMgt;
}
