// Builds the structured task message text sent to the NAL Sales Order Agent from a manually entered order request.
codeunit 50105 NALSOAgentRequestMgt
{
    Access = Internal;

    procedure BuildTaskMessage(var TempNALSOAgentRequestLine: Record NALSOAgentRequestLine temporary): Text
    var
        MessageBuilder: TextBuilder;
        CustomerNo: Code[20];
    begin
        DeleteBlankLines(TempNALSOAgentRequestLine);

        if TempNALSOAgentRequestLine.IsEmpty() then
            Error(NoLinesErr);

        TempNALSOAgentRequestLine.FindSet();
        CustomerNo := TempNALSOAgentRequestLine."Customer No.";
        repeat
            if TempNALSOAgentRequestLine."Customer No." <> CustomerNo then
                Error(OneCustomerOnlyErr);
            if TempNALSOAgentRequestLine."Item No." = '' then
                Error(ItemRequiredErr, TempNALSOAgentRequestLine."Line No.");
            if TempNALSOAgentRequestLine.Quantity = 0 then
                Error(QuantityRequiredErr, TempNALSOAgentRequestLine."Line No.");
        until TempNALSOAgentRequestLine.Next() = 0;

        MessageBuilder.AppendLine(StrSubstNo(CustomerLineLbl, CustomerNo));
        TempNALSOAgentRequestLine.FindSet();
        repeat
            MessageBuilder.AppendLine(
                StrSubstNo(
                    RequestLineLbl,
                    TempNALSOAgentRequestLine."Item No.",
                    TempNALSOAgentRequestLine.Quantity,
                    TempNALSOAgentRequestLine."Requested Delivery Date"));
        until TempNALSOAgentRequestLine.Next() = 0;

        exit(MessageBuilder.ToText());
    end;

    /// <summary>
    /// Builds the task message for a file-based request (dragged-and-dropped email or PDF).
    /// Falls back to the strict structured message when lines were also entered.
    /// </summary>
    procedure BuildAttachmentTaskMessage(var TempNALSOAgentRequestLine: Record NALSOAgentRequestLine temporary): Text
    begin
        DeleteBlankLines(TempNALSOAgentRequestLine);

        if TempNALSOAgentRequestLine.IsEmpty() then
            exit(AttachmentOnlyMessageTxt);
        exit(BuildTaskMessage(TempNALSOAgentRequestLine));
    end;

    /// <summary>
    /// Removes filler lines that the editable list auto-inserts (no customer, item, or quantity entered).
    /// </summary>
    local procedure DeleteBlankLines(var TempNALSOAgentRequestLine: Record NALSOAgentRequestLine temporary)
    begin
        TempNALSOAgentRequestLine.Reset();
        TempNALSOAgentRequestLine.SetRange("Customer No.", '');
        TempNALSOAgentRequestLine.SetRange("Item No.", '');
        TempNALSOAgentRequestLine.SetRange(Quantity, 0);
        TempNALSOAgentRequestLine.DeleteAll();
        TempNALSOAgentRequestLine.Reset();
    end;

    /// <summary>
    /// Default message used when a file is sent to the agent without any request lines (e.g. from a role center shortcut).
    /// </summary>
    procedure GetDefaultAttachmentMessage(): Text
    begin
        exit(AttachmentOnlyMessageTxt);
    end;

    /// <summary>
    /// Lets the user pick/drag-and-drop a file (email or PDF), attach it to a new agent task, and pick which agent to send it to.
    /// Returns true if a task was created.
    /// </summary>
    procedure SendAttachmentToAgent(MessageTxt: Text): Boolean
    var
        AgentSetup: Codeunit "Agent Setup";
        AgentTaskBuilder: Codeunit "Agent Task Builder";
        AgentTaskMessageBuilder: Codeunit "Agent Task Message Builder";
        Agent: Codeunit Agent;
        AgentTask: Record "Agent Task";
        AgentUserSecurityId: Guid;
    begin
        AgentTaskMessageBuilder.Initialize(MessageTxt);
        if not AgentTaskMessageBuilder.UploadAttachment() then
            exit(false);

        if not AgentSetup.OpenAgentLookup(Enum::"Agent Metadata Provider"::"NAL Sales Order Agent", AgentUserSecurityId) then
            exit(false);

        if IsNullGuid(AgentUserSecurityId) then
            Error(NoAgentSelectedErr);

        AgentTask := AgentTaskBuilder
            .Initialize(AgentUserSecurityId, FileTaskTitleLbl)
            .AddTaskMessage(AgentTaskMessageBuilder)
            .Create();

        Message(TaskAssignedMsg, AgentTask.ID, Agent.GetDisplayName(AgentUserSecurityId));
        exit(true);
    end;

    var
        NoLinesErr: Label 'Enter at least one order line before sending the request to the agent.';
        OneCustomerOnlyErr: Label 'All lines must use the same Customer No. Split requests for different customers into separate tasks.';
        ItemRequiredErr: Label 'Line %1 is missing an Item No.', Comment = '%1 = Line No.';
        QuantityRequiredErr: Label 'Line %1 must have a Quantity greater than 0.', Comment = '%1 = Line No.';
        CustomerLineLbl: Label 'Customer No.: %1', Locked = true, Comment = '%1 = Customer No.';
        RequestLineLbl: Label 'Line: Item No. %1, Quantity %2, Requested Delivery Date %3', Locked = true, Comment = '%1 = Item No., %2 = Quantity, %3 = Requested Delivery Date';
        AttachmentOnlyMessageTxt: Label 'See the attached file for the customer''s order request. Extract the customer, requested items, quantities, and requested delivery date from the file.', Locked = true;
        FileTaskTitleLbl: Label 'Create sales quote from attached email or PDF';
        NoAgentSelectedErr: Label 'No NAL Sales Order Agent was selected.';
        TaskAssignedMsg: Label 'Task %1 assigned to agent %2.', Comment = '%1 = Task ID, %2 = Agent display name';
}
