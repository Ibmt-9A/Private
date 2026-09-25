// Lets the agent add a text-only sales line (no item number) through a single action instead of editing Type/No./Description
// directly in the grid, which can trigger an item lookup that fails when the text isn't a unique match.
pageextension 50100 NALSOAgentSalesQuoteSubformExt extends "Sales Quote Subform"
{
    actions
    {
        addlast(processing)
        {
            action(NALSOAddTextLine)
            {
                Caption = 'Add Text Line';
                ToolTip = 'Adds a new line without an item number, right after the currently selected line - for a specification note or an item that could not be matched by number. Select the line it belongs after first, then type the full text in the dialog. No item lookup is performed.';
                ApplicationArea = All;
                Image = Comment;

                trigger OnAction()
                var
                    NALSOAgentRequestMgt: Codeunit NALSOAgentRequestMgt;
                    NALSOAgentTextLineDialog: Page NALSOAgentTextLineDialog;
                begin
                    if NALSOAgentTextLineDialog.RunModal() <> Action::OK then
                        exit;

                    NALSOAgentRequestMgt.InsertTextLine(Rec, NALSOAgentTextLineDialog.GetDescription());
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
