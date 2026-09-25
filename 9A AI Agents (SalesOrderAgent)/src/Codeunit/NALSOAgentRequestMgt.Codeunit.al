// Builds and sends agent task messages (file attachment or pasted text) for the NAL Sales Order Agent, and adds text lines to sales quotes.
codeunit 50105 NALSOAgentRequestMgt
{
    Access = Internal;

    /// <summary>
    /// Adds a text-only sales line (Type blank, No. empty) directly via AL, bypassing the grid's item lookup entirely.
    /// Inserted right after AfterSalesLine, so it keeps the same order as on the source document.
    /// </summary>
    procedure InsertTextLine(var AfterSalesLine: Record "Sales Line"; TextDescription: Text[100])
    var
        NextSalesLine: Record "Sales Line";
        NewSalesLine: Record "Sales Line";
        NewLineNo: Integer;
        Gap: Integer;
    begin
        NextSalesLine.SetRange("Document Type", AfterSalesLine."Document Type");
        NextSalesLine.SetRange("Document No.", AfterSalesLine."Document No.");
        NextSalesLine.SetFilter("Line No.", '>%1', AfterSalesLine."Line No.");
        if NextSalesLine.FindFirst() then begin
            Gap := NextSalesLine."Line No." - AfterSalesLine."Line No.";
            if Gap > 1 then
                NewLineNo := AfterSalesLine."Line No." + Gap div 2
            else
                // No room to insert between the two lines - fall back to appending right after the next line instead.
                NewLineNo := NextSalesLine."Line No." + 10000;
        end else
            NewLineNo := AfterSalesLine."Line No." + 10000;

        NewSalesLine.Init();
        NewSalesLine."Document Type" := AfterSalesLine."Document Type";
        NewSalesLine."Document No." := AfterSalesLine."Document No.";
        NewSalesLine."Line No." := NewLineNo;
        NewSalesLine.Insert(true);
        NewSalesLine.Validate(Type, NewSalesLine.Type::" ");
        NewSalesLine.Description := TextDescription;
        NewSalesLine.Modify(true);
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
        FileManagement: Codeunit "File Management";
        Agent: Codeunit Agent;
        AgentTask: Record "Agent Task";
        AgentUserSecurityId: Guid;
        AttachmentInStream: InStream;
        AttachmentFileName: Text;
        AttachmentMimeType: Text;
    begin
        if not UploadIntoStream(UploadDialogTitleLbl, '', UploadFileFilterTxt, AttachmentFileName, AttachmentInStream) then
            exit(false);

        // Outlook drag-and-drop items don't always carry a browser-detected MIME type, so resolve it from the file extension instead.
        AttachmentMimeType := FileManagement.GetFileNameMimeType(AttachmentFileName);
        if AttachmentMimeType = '' then begin
            // Dragging straight out of Outlook can hand the browser the whole email (.msg/.eml) instead of the attachment itself.
            if FileManagement.GetExtension(AttachmentFileName) in ['msg', 'eml'] then
                Error(OutlookDragErr, AttachmentFileName);
            Error(UnsupportedFileTypeErr, AttachmentFileName);
        end;

        AgentTaskMessageBuilder.Initialize(MessageTxt);
        AgentTaskMessageBuilder.AddAttachment(CopyStr(AttachmentFileName, 1, 250), CopyStr(AttachmentMimeType, 1, 100), AttachmentInStream);
        // Skips the incoming-message review step by request, even though the attachment content originates from the customer.
        AgentTaskMessageBuilder.SetRequiresReview(false);

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

    /// <summary>
    /// Lets the user paste order request text (for example copied from an email body) and send it to the agent as a task.
    /// Returns true if a task was created.
    /// </summary>
    procedure SendTextToAgent(OrderText: Text): Boolean
    var
        AgentSetup: Codeunit "Agent Setup";
        AgentTaskBuilder: Codeunit "Agent Task Builder";
        AgentTaskMessageBuilder: Codeunit "Agent Task Message Builder";
        Agent: Codeunit Agent;
        AgentTask: Record "Agent Task";
        AgentUserSecurityId: Guid;
    begin
        AgentTaskMessageBuilder.Initialize(StrSubstNo(PastedTextMessageLbl, OrderText));
        // Skips the incoming-message review step by request, even though the pasted content originates from the customer.
        AgentTaskMessageBuilder.SetRequiresReview(false);

        if not AgentSetup.OpenAgentLookup(Enum::"Agent Metadata Provider"::"NAL Sales Order Agent", AgentUserSecurityId) then
            exit(false);

        if IsNullGuid(AgentUserSecurityId) then
            Error(NoAgentSelectedErr);

        AgentTask := AgentTaskBuilder
            .Initialize(AgentUserSecurityId, PastedTextTaskTitleLbl)
            .AddTaskMessage(AgentTaskMessageBuilder)
            .Create();

        Message(TaskAssignedMsg, AgentTask.ID, Agent.GetDisplayName(AgentUserSecurityId));
        exit(true);
    end;

    var
        AttachmentOnlyMessageTxt: Label 'See the attached file for the customer''s order request. Extract the customer, requested items, quantities, and requested delivery date from the file.', Locked = true;
        FileTaskTitleLbl: Label 'Create sales quote from attached email or PDF';
        PastedTextMessageLbl: Label 'The customer''s order request was pasted as plain text below, for example copied directly from an email body. Extract the customer, requested items, quantities, and requested delivery date from this text: %1', Comment = '%1 = Pasted order text', Locked = true;
        PastedTextTaskTitleLbl: Label 'Create sales quote from pasted order text';
        NoAgentSelectedErr: Label 'No NAL Sales Order Agent was selected.';
        TaskAssignedMsg: Label 'Task %1 assigned to agent %2.', Comment = '%1 = Task ID, %2 = Agent display name';
        UploadDialogTitleLbl: Label 'Select a PDF or image file';
        UploadFileFilterTxt: Label 'PDF files (*.pdf)|*.pdf|Image files (*.png;*.jpg;*.jpeg)|*.png;*.jpg;*.jpeg|All files (*.*)|*.*', Locked = true;
        UnsupportedFileTypeErr: Label 'The file %1 has an unrecognized file type and cannot be attached. Save it as a PDF, PNG, or JPG file first and try again.', Comment = '%1 = File name';
        OutlookDragErr: Label 'The file %1 looks like the email itself, not the attachment. Open the PDF/image attachment in its own window in Outlook and drag it from there, or save it to disk first, then attach that file.', Comment = '%1 = File name';
}
