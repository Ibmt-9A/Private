// Role Center used as the starting point for the NAL Zero Inventory Agent.
page 50106 NALZeroInvAgentRoleCenter
{
    PageType = RoleCenter;
    Caption = 'NAL Zero Inventory Agent Role Center';

    layout
    {
        area(RoleCenter)
        {
        }
    }

    actions
    {
        area(Sections)
        {
            group(Items)
            {
                Caption = 'Items';

                action(ItemsList)
                {
                    Caption = 'Items';
                    ToolTip = 'View the list of items.';
                    ApplicationArea = All;
                    Image = Item;
                    RunObject = page "Item List";
                }
            }
        }
    }
}
