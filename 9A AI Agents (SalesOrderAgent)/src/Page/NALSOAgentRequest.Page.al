// Lets a user enter a structured sales order request (customer + item lines) and hand it off to the NAL Sales Order Agent.
page 50103 NALSOAgentRequest
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Sales Order Agent Requests';
    SourceTable = NALSOAgentRequestLine;
    SourceTableTemporary = true;
    Editable = true;
    DeleteAllowed = true;
    InsertAllowed = true;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer the order request is for. Use the same customer on every line.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the name of the customer.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the requested item.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the item.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the requested quantity.';
                }
                field("Requested Delivery Date"; Rec."Requested Delivery Date")
                {
                    ToolTip = 'Specifies the delivery date requested by the customer.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SendToSalesOrderAgent)
            {
                Caption = 'Send to Sales Order Agent';
                ToolTip = 'Ask the NAL Sales Order Agent to create a sales quote from the entered request lines.';
                Image = Task;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    AgentSetup: Codeunit "Agent Setup";
                    AgentTaskBuilder: Codeunit "Agent Task Builder";
                    Agent: Codeunit Agent;
                    NALSOAgentRequestMgt: Codeunit NALSOAgentRequestMgt;
                    AgentTask: Record "Agent Task";
                    AgentUserSecurityId: Guid;
                    TaskMessageTxt: Text;
                begin
                    TaskMessageTxt := NALSOAgentRequestMgt.BuildTaskMessage(Rec);

                    if not AgentSetup.OpenAgentLookup(Enum::"Agent Metadata Provider"::"NAL Sales Order Agent", AgentUserSecurityId) then
                        exit;

                    if IsNullGuid(AgentUserSecurityId) then
                        Error(NoAgentSelectedErr);

                    AgentTask := AgentTaskBuilder
                        .Initialize(AgentUserSecurityId, TaskTitleLbl)
                        .AddTaskMessage(CopyStr(UserId(), 1, 250), TaskMessageTxt)
                        .Create();

                    Rec.DeleteAll();

                    Message(TaskAssignedMsg, AgentTask.ID, Agent.GetDisplayName(AgentUserSecurityId));
                end;
            }
            action(AttachFileToSalesOrderAgent)
            {
                Caption = 'Send Email or PDF to Agent';
                ToolTip = 'Attach a customer email or PDF file and let the NAL Sales Order Agent read it and create a sales quote from it.';
                Image = Attach;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NALSOAgentRequestMgt: Codeunit NALSOAgentRequestMgt;
                    MessageTxt: Text;
                begin
                    MessageTxt := NALSOAgentRequestMgt.BuildAttachmentTaskMessage(Rec);
                    if NALSOAgentRequestMgt.SendAttachmentToAgent(MessageTxt) then
                        Rec.DeleteAll();
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Line No." := GetNextLineNo();
    end;

    local procedure GetNextLineNo(): Integer
    var
        TempNALSOAgentRequestLine: Record NALSOAgentRequestLine temporary;
    begin
        TempNALSOAgentRequestLine.Copy(Rec, true);
        if TempNALSOAgentRequestLine.FindLast() then
            exit(TempNALSOAgentRequestLine."Line No." + 10000);
        exit(10000);
    end;

    var
        TaskTitleLbl: Label 'Create sales quote from order request';
        NoAgentSelectedErr: Label 'No NAL Sales Order Agent was selected.';
        TaskAssignedMsg: Label 'Task %1 assigned to agent %2.', Comment = '%1 = Task ID, %2 = Agent display name';
}
