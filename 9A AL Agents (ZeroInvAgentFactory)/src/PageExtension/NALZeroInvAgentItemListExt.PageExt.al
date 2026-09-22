// Lets a user hand off zero-inventory blocking to the NAL Zero Inventory Agent from the Item List.
pageextension 50115 NALZeroInvAgentItemListExt extends "Item List"
{
    actions
    {
        addlast(processing)
        {
            action(NALSendToZeroInventoryAgent)
            {
                Caption = 'Send to Zero Inventory Agent';
                ToolTip = 'Ask the NAL Zero Inventory Agent to review items and block those with zero on-hand inventory.';
                Image = Task;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    AgentSetup: Codeunit "Agent Setup";
                    AgentTaskBuilder: Codeunit "Agent Task Builder";
                    Agent: Codeunit Agent;
                    AgentTask: Record "Agent Task";
                    AgentUserSecurityId: Guid;
                begin
                    if not AgentSetup.OpenAgentLookup(Enum::"Agent Metadata Provider"::"NAL Zero Inventory Agent", AgentUserSecurityId) then
                        exit;

                    if IsNullGuid(AgentUserSecurityId) then
                        Error(NoAgentSelectedErr);

                    AgentTask := AgentTaskBuilder
                        .Initialize(AgentUserSecurityId, TaskTitleLbl)
                        .AddTaskMessage(CopyStr(UserId(), 1, 250), TaskMessageTxt)
                        .Create();

                    Message(TaskAssignedMsg, AgentTask.ID, Agent.GetDisplayName(AgentUserSecurityId));
                end;
            }
        }
    }

    var
        TaskTitleLbl: Label 'Block items with zero inventory';
        TaskMessageTxt: Label 'Please review the items and set Blocked = Yes for every inventory item where the on-hand Inventory quantity is 0 and it is not already blocked.', Locked = true;
        NoAgentSelectedErr: Label 'No NAL Zero Inventory Agent was selected.';
        TaskAssignedMsg: Label 'Task %1 assigned to agent %2.', Comment = '%1 = Task ID, %2 = Agent display name';
}
