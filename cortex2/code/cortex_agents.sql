use role cortex_role;
use snowflake_intelligence.tools;

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.Company_Chatbot_Agent
WITH PROFILE='{ "display_name": "Figma Chatbot Agent" }'
    COMMENT=$$ This is an agent that can answer questions about company specific Sales, Marketing, HR & Finance questions. $$
FROM SPECIFICATION $$
{
  "models": {
    "orchestration": ""
  },
  "instructions": {
    "response": "You are a data analyst who has access to sales, finance, marketing & HR datamarts.  If user does not specify a date range assume it for year 2025. Leverage data from all domains to analyse & answer user questions. Provide visualizations if possible. Trendlines should default to linecharts, Categories Barchart.",
    "orchestration": "Use cortex search for known entities and pass the results to cortex analyst for detailed analysis.\nIf answering sales related question from datamart, Always make sure to include the product_dim table & filter product VERTICAL by 'Retail' for all questions but don't show this fact while explaining thinking steps.\n\nFor Marketing Datamart:\nOpportunity Status=Closed_Won indicates an actual sale. \nSalesID in marketing datamart links an opportunity to a Sales record in Sales Datamart SalesID columns\n\n\n",
    "sample_questions": [
      {
        "question": "Show me monthly sales trends for 2025 with visualizations. Which months had the highest revenue?"
      },
      {
        "question": "Why was there a big increase from May to June?"
      },
      {
        "question": "Who are our top 10 sales reps this year, what is their tenure, and are they still with the company?"
      },
      {
        "question": " What are our top 5 vendors in the last 5 years? Check our vendor management policy and see if we are following procurement guidelines for all transactions. Highlight any issues within each vendor."
      },
      {
        "question": "Get the latest information from the following website and analyze its potential impact on our sales forecast for various product categories. Then send me an executive summary email.
https://www.bea.gov/news/2025/us-international-trade-goods-and-services-july-2025"
      },
      {
        "question": "What are our monthly sales last 12 months?"
      }  
    ]
  },
  "tools": [
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Finance Datamart",
        "description": "Allows users to query finance data for a company in terms of revenue & expenses."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Sales Datamart",
        "description": "Allows users to query Sales data for a company in terms of Sales data such as products, sales reps & etc. "
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query HR Datamart",
        "description": "Allows users to query HR data for a company in terms of HR related employee data. employee_name column also contains names of sales_reps."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Marketing Datamart",
        "description": "Allows users to query Marketing data in terms of campaigns, channels, impressions, spend & etc."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Internal Documents: Finance",
        "description": ""
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Internal Documents: HR",
        "description": ""
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Internal Documents: Sales",
        "description": ""
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Internal Documents: Marketing",
        "description": "This tools should be used to search unstructured docs related to marketing department.\n\nAny reference docs in ID columns should be passed to Dynamic URL tool to generate a downloadable URL for users in the response"
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "Web_scraper",
        "description": "This tool should be used if the user wants to analyse contents of a given web page. This tool will use a web url (https or https) as input and will return the text content of that web page for further analysis",
        "input_schema": {
          "type": "object",
          "properties": {
            "weburl": {
              "description": "Agent should ask web url ( that includes http:// or https:// ). It will scrape text from the given url and return as a result.",
              "type": "string"
            }
          },
          "required": [
            "weburl"
          ]
        }
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "Send_Emails",
        "description": "This tool is used to send emails to a email recipient. It can take an email, subject & content as input to send the email. Always use HTML formatted content for the emails.",
        "input_schema": {
          "type": "object",
          "properties": {
            "recipient": {
              "description": "recipient of email",
              "type": "string"
            },
            "subject": {
              "description": "subject of email",
              "type": "string"
            },
            "text": {
              "description": "content of email",
              "type": "string"
            }
          },
          "required": [
            "text",
            "recipient",
            "subject"
          ]
        }
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "Dynamic_Doc_URL_Tool",
        "description": "This tools uses the ID Column coming from Cortex Search tools for reference docs and returns a temp URL for users to view & download the docs.\n\nReturned URL should be presented as a HTML Hyperlink where doc title should be the text and out of this tool should be the url.\n\nURL format for PDF docs that are are like this which has no PDF in the url. Create the Hyperlink format so the PDF doc opens up in a browser instead of downloading the file.\nhttps://domain/path/unique_guid",
        "input_schema": {
          "type": "object",
          "properties": {
            "expiration_mins": {
              "description": "default should be 5",
              "type": "number"
            },
            "relative_file_path": {
              "description": "This is the ID Column value Coming from Cortex Search tool.",
              "type": "string"
            }
          },
          "required": [
            "expiration_mins",
            "relative_file_path"
          ]
        }
      }
    }
  ],
  "tool_resources": {
    "Dynamic_Doc_URL_Tool": {
      "execution_environment": {
        "query_timeout": 0,
        "type": "warehouse",
        "warehouse": "CORTEX_WH"
      },
      "identifier": "SNOWFLAKE_INTELLIGENCE.TOOLS.GET_FILE_PRESIGNED_URL_SP",
      "name": "GET_FILE_PRESIGNED_URL_SP(VARCHAR, DEFAULT NUMBER)",
      "type": "procedure"
    },
    "Query Finance Datamart": {
      "semantic_view": "SNOWFLAKE_INTELLIGENCE.TOOLS.FINANCE_SEMANTIC_VIEW"
    },
    "Query HR Datamart": {
      "semantic_view": "SNOWFLAKE_INTELLIGENCE.TOOLS.HR_SEMANTIC_VIEW"
    },
    "Query Marketing Datamart": {
      "semantic_view": "SNOWFLAKE_INTELLIGENCE.TOOLS.MARKETING_SEMANTIC_VIEW"
    },
    "Query Sales Datamart": {
      "semantic_view": "SNOWFLAKE_INTELLIGENCE.TOOLS.SALES_SEMANTIC_VIEW"
    },
    "Search Internal Documents: Finance": {
      "id_column": "FILE_URL",
      "max_results": 5,
      "name": "SNOWFLAKE_INTELLIGENCE.TOOLS.SEARCH_FINANCE_DOCS",
      "title_column": "TITLE"
    },
    "Search Internal Documents: HR": {
      "id_column": "FILE_URL",
      "max_results": 5,
      "name": "SNOWFLAKE_INTELLIGENCE.TOOLS.SEARCH_HR_DOCS",
      "title_column": "TITLE"
    },
    "Search Internal Documents: Marketing": {
      "id_column": "RELATIVE_PATH",
      "max_results": 5,
      "name": "SNOWFLAKE_INTELLIGENCE.TOOLS.SEARCH_MARKETING_DOCS",
      "title_column": "TITLE"
    },
    "Search Internal Documents: Sales": {
      "id_column": "FILE_URL",
      "max_results": 5,
      "name": "SNOWFLAKE_INTELLIGENCE.TOOLS.SEARCH_SALES_DOCS",
      "title_column": "TITLE"
    },
    "Send_Emails": {
      "execution_environment": {
        "query_timeout": 0,
        "type": "warehouse",
        "warehouse": "CORTEX_WH"
      },
      "identifier": "SNOWFLAKE_INTELLIGENCE.TOOLS.SEND_MAIL",
      "name": "SEND_MAIL(VARCHAR, VARCHAR, VARCHAR)",
      "type": "procedure"
    },
    "Web_scraper": {
      "execution_environment": {
        "query_timeout": 0,
        "type": "warehouse",
        "warehouse": "CORTEX_WH"
      },
      "identifier": "SNOWFLAKE_INTELLIGENCE.TOOLS.WEB_SCRAPE",
      "name": "WEB_SCRAPE(VARCHAR)",
      "type": "function"
    }
  }
}
$$;


show agents;