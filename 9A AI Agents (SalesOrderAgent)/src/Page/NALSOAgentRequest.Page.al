// Lets a user send a PDF/image attachment or pasted order text to the NAL Sales Order Agent.
page 50103 NALSOAgentRequest
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Sales Order Agent Requests';

    layout
    {
        area(Content)
        {
        }
    }

    actions
    {
        area(Processing)
        {
            action(AttachFileToSalesOrderAgent)
            {
                Caption = 'Send PDF or Image to Agent';
                ToolTip = 'Attach a PDF or image file (for example a PDF export of a customer email, a scanned order, or a photo) and let the NAL Sales Order Agent read it and create a sales quote from it. Only PDF, PNG, and JPG files are supported - save an Outlook email as PDF first (File > Save As > PDF).';
                Image = Attach;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NALSOAgentRequestMgt: Codeunit NALSOAgentRequestMgt;
                begin
                    NALSOAgentRequestMgt.SendAttachmentToAgent(NALSOAgentRequestMgt.GetDefaultAttachmentMessage());
                end;
            }
            action(SendTextToSalesOrderAgent)
            {
                Caption = 'Send Pasted Order Text to Agent';
                ToolTip = 'Paste order request text copied directly from an email body (instead of attaching a file) and let the NAL Sales Order Agent read it and create a sales quote from it.';
                Image = Comment;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NALSOAgentPasteTextRequest: Page NALSOAgentPasteTextRequest;
                begin
                    NALSOAgentPasteTextRequest.RunModal();
                end;
            }
        }
    }
}
