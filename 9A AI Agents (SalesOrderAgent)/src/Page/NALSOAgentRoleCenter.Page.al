// Role Center used as the starting point for the NAL Sales Order Agent.
page 50102 NALSOAgentRoleCenter
{
    PageType = RoleCenter;
    Caption = 'NAL Sales Order Agent Role Center';

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
            group(SalesRequests)
            {
                Caption = 'Sales Order Requests';

                action(OrderRequests)
                {
                    Caption = 'Sales Order Requests';
                    ToolTip = 'Enter a structured sales order request to send to the agent.';
                    ApplicationArea = All;
                    Image = Sales;
                    RunObject = page NALSOAgentRequest;
                }
                action(AttachFileShortcut)
                {
                    Caption = 'Send PDF or Image to Agent';
                    ToolTip = 'Attach a PDF or image file (for example a PDF export of a customer email, a scanned order, or a photo) and let the NAL Sales Order Agent read it and create a sales quote from it. Only PDF, PNG, and JPG files are supported - save an Outlook email as PDF first (File > Save As > PDF).';
                    ApplicationArea = All;
                    Image = Attach;
                    RunObject = page NALSOAgentAttachShortcut;
                }
                action(PasteTextShortcut)
                {
                    Caption = 'Send Pasted Order Text to Agent';
                    ToolTip = 'Paste order request text copied directly from an email body (instead of attaching a file) and let the NAL Sales Order Agent read it and create a sales quote from it.';
                    ApplicationArea = All;
                    Image = Comment;
                    RunObject = page NALSOAgentPasteTextRequest;
                }
            }
            group(Sales)
            {
                Caption = 'Sales';

                action(SalesQuotes)
                {
                    Caption = 'Sales Quotes';
                    ToolTip = 'View the list of sales quotes.';
                    ApplicationArea = All;
                    Image = Quote;
                    RunObject = page "Sales Quotes";
                }
                action(SalesOrders)
                {
                    Caption = 'Sales Orders';
                    ToolTip = 'View the list of sales orders.';
                    ApplicationArea = All;
                    Image = Order;
                    RunObject = page "Sales Order List";
                }
                action(Customers)
                {
                    Caption = 'Customers';
                    ToolTip = 'View the list of customers.';
                    ApplicationArea = All;
                    Image = Customer;
                    RunObject = page "Customer List";
                }
                action(Items)
                {
                    Caption = 'Items';
                    ToolTip = 'View the list of items, including exact item numbers and on-hand inventory.';
                    ApplicationArea = All;
                    Image = Item;
                    RunObject = page "Item List";
                }
            }
        }
    }
}
