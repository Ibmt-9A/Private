// Lets a user paste order request text copied directly from an email body (instead of attaching a file) and send it to the agent.
page 50106 NALSOAgentPasteTextRequest
{
    PageType = Card;
    Caption = 'Send Pasted Order Text to Agent';
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(OrderText; OrderText)
                {
                    ApplicationArea = All;
                    Caption = 'Order Text';
                    ToolTip = 'Specifies the customer''s order request text, for example copied directly from an email body. Paste as plain text (Ctrl+Shift+V) to avoid carrying over formatting from the source email.';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
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
                ToolTip = 'Sends the pasted text to the NAL Sales Order Agent to create a sales quote from it.';
                Image = Task;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NALSOAgentRequestMgt: Codeunit NALSOAgentRequestMgt;
                begin
                    if OrderText.Trim() = '' then
                        Error(NoTextEnteredErr);

                    if NALSOAgentRequestMgt.SendTextToAgent(OrderText) then begin
                        OrderText := '';
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }

    var
        OrderText: Text;
        NoTextEnteredErr: Label 'Paste the order text before sending it to the agent.';
}
