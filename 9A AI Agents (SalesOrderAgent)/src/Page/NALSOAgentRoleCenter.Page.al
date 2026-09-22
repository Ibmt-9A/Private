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
            }
        }
    }
}
