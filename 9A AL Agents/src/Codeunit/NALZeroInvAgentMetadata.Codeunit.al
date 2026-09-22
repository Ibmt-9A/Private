// Implements IAgentMetadata: provides runtime metadata for NAL Zero Inventory Agent instances.
codeunit 50108 NALZeroInvAgentMetadata implements IAgentMetadata
{
    Access = Internal;

    procedure GetInitials(AgentUserId: Guid): Text[4]
    begin
        exit(NALZeroInvAgentSetupMgt.GetInitials());
    end;

    procedure GetSetupPageId(AgentUserId: Guid): Integer
    begin
        exit(NALZeroInvAgentSetupMgt.GetSetupPageId());
    end;

    procedure GetSummaryPageId(AgentUserId: Guid): Integer
    begin
        exit(NALZeroInvAgentSetupMgt.GetSummaryPageId());
    end;

    procedure GetAgentTaskMessagePageId(AgentUserId: Guid; MessageId: Guid): Integer
    begin
        exit(Page::"Agent Task Message Card");
    end;

    procedure GetAgentAnnotations(AgentUserId: Guid; var Annotations: Record "Agent Annotation")
    begin
        Clear(Annotations);
    end;

    var
        NALZeroInvAgentSetupMgt: Codeunit NALZeroInvAgentSetupMgt;
}
