pageextension 51100 "PTE_CompanyInformation" extends "Company Information"
{
    layout
    {
        addlast(General)
        {

        }
    }
    actions
    {
        addlast(Processing)
        {
            action(TestClientType)
            {
                Caption = 'Test Client Type';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = PostMail;

                trigger OnAction()
                var
                    clientType: ClientType;
                begin
                    clientType := Session.CurrentClientType();
                    case clientType of
                        ClientType::Windows:
                            Message('Windows/PC client');
                        ClientType::Web:
                            Message('Web client (browser på PC)');
                        ClientType::Tablet:
                            Message('Tablet client');
                        ClientType::Phone:
                            Message('Phone client');
                        else
                            Message('Ukendt klienttype');
                    end;
                end;
            }

            action(CorrectItem)
            {
                caption = 'Correct Item';
                ApplicationArea = all;

                trigger OnAction()
                var
                    ToolActions: Codeunit "ToolActions";
                begin
                    ToolActions.CorrectItem();
                end;
            }
        }
    }
}