// Bounce page: Role Center actions can't run code directly, so this opens, triggers the file upload, and closes itself.
page 50104 NALSOAgentAttachShortcut
{
    PageType = Card;
    Caption = 'Send PDF or Image to Agent';
    ApplicationArea = All;
    Extensible = false;

    layout
    {
        area(Content)
        {
        }
    }

    trigger OnOpenPage()
    var
        NALSOAgentRequestMgt: Codeunit NALSOAgentRequestMgt;
    begin
        NALSOAgentRequestMgt.SendAttachmentToAgent(NALSOAgentRequestMgt.GetDefaultAttachmentMessage());
        CurrPage.Close();
    end;
}
