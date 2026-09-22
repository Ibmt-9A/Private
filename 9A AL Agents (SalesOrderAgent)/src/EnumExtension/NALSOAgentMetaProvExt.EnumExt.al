// Registers the NAL Sales Order Agent as a selectable agent type.
enumextension 50101 NALSOAgentMetaProvExt extends "Agent Metadata Provider"
{
    value(50101; "NAL Sales Order Agent")
    {
        Caption = 'NAL Sales Order Agent';
        Implementation = IAgentFactory = NALSOAgentFactory, IAgentMetadata = NALSOAgentMetadata, IAgentTaskExecution = NALSOAgentTaskExecution;
    }
}
