enum 51002 NALVideoAnalysisProvider
{
    Extensible = true;
    Caption = 'AI Provider';

    value(0; AzureOpenAI)
    {
        Caption = 'Azure OpenAI';
    }
    value(1; GitHubModels)
    {
        Caption = 'GitHub Models';
    }
    value(2; GoogleGemini)
    {
        Caption = 'Google Gemini';
    }
}
