#!/usr/bin/env python3
"""
Lightweight MCP Client for Snowflake SEC Database
Makes direct HTTP calls to MCP server - no simulated data

CONFIGURATION FOR COLLEAGUES:
To adapt this client for your MCP server, update these parameters below:
1. MCP_SERVER_URL: Your MCP server endpoint URL
2. MCP_AUTH_TOKEN: Your bearer token for authentication  
3. MCP_SEARCH_TOOL: Name of your document search tool
4. MCP_ANALYST_TOOL: Name of your data analysis/SQL generation tool
"""

import os
import json
import logging
import requests
from flask import Flask, render_template, request, jsonify, session
from datetime import datetime
from typing import Dict, List, Any, Optional
import uuid

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'mcp-client-dev-key-change-in-production')

# MCP Server Configuration (from mcp.json)
MCP_SERVER_URL = "https://orgname-accountname.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/tools/mcp-servers/snowflake_mcp_server"
MCP_AUTH_TOKEN = "pat token"

# MCP Tool Names Configuration
MCP_SEARCH_TOOL = "Snowflake Documentation Search"          # Tool for document/filing search
MCP_ANALYST_TOOL = "query_semanctic_view" # Tool for data analysis/SQL generation

class MCPClient:
    """Lightweight MCP Protocol Client for direct server communication"""
    
    def __init__(self):
        self.base_url = MCP_SERVER_URL
        self.headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': f'Bearer {MCP_AUTH_TOKEN}'
        }
        self.session = requests.Session()
        self.session.headers.update(self.headers)
    
    def _make_rpc_call(self, method: str, params: Dict[str, Any] = None) -> Dict[str, Any]:
        """Make MCP JSON-RPC call to server"""
        payload = {
            "jsonrpc": "2.0",
            "id": 12345,  # Use a simple integer ID like the working curl example
            "method": method,
            "params": params or {}
        }
        
        try:
            logger.info(f"📡 MCP RPC Call: {method} with params: {params}")
            logger.info(f"📡 Payload: {json.dumps(payload, indent=2)}")
            
            response = self.session.post(
                self.base_url, 
                json=payload, 
                timeout=60,  # Increased timeout
                verify=True  # Ensure SSL verification
            )
            
            logger.info(f"📡 Response status: {response.status_code}")
            logger.info(f"📡 Response headers: {dict(response.headers)}")
            
            if response.status_code == 200:
                result = response.json()
                logger.info(f"📡 Response body: {json.dumps(result, indent=2)}")
                
                if 'result' in result:
                    logger.info(f"✅ MCP Call successful: {method}")
                    return result['result']
                elif 'error' in result:
                    logger.error(f"❌ MCP Error: {result['error']}")
                    raise Exception(f"MCP Error: {result['error']}")
                else:
                    logger.error(f"❌ Unexpected response format: {result}")
                    raise Exception(f"Unexpected response format: {result}")
            else:
                logger.error(f"❌ HTTP Error {response.status_code}: {response.text}")
                raise Exception(f"HTTP {response.status_code}: {response.text}")
                
        except requests.RequestException as e:
            logger.error(f"❌ Request failed: {e}")
            raise Exception(f"Request failed: {e}")
    
    def list_tools(self) -> List[Dict[str, Any]]:
        """Get available MCP tools"""
        result = self._make_rpc_call("tools/list")
        return result.get('tools', [])
    
    def call_tool(self, tool_name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
        """Call specific MCP tool with arguments"""
        params = {
            "name": tool_name,
            "arguments": arguments
        }
        return self._make_rpc_call("tools/call", params)

def parse_analyst_result(result: Dict[str, Any], query: str) -> Dict[str, Any]:
    """Parse the analyst result to extract SQL and provide formatted output"""
    try:
        # Extract SQL from the analyst result
        sql_statement = None
        if 'content' in result and isinstance(result['content'], list):
            for item in result['content']:
                if item.get('type') == 'text' and 'text' in item:
                    # The text contains JSON with the SQL statement
                    text_content = item['text']
                    try:
                        parsed_json = json.loads(text_content)
                        if 'statement' in parsed_json:
                            sql_statement = parsed_json['statement']
                            break
                    except json.JSONDecodeError:
                        # If not JSON, treat as plain text
                        sql_statement = text_content
        
        if not sql_statement:
            return {
                'type': 'analysis',
                'sql_query': None,
                'explanation': f"Generated analysis for: {query}",
                'executed': False,
                'error': 'No SQL statement found in response'
            }
        
        # Clean up the SQL statement
        sql_statement = sql_statement.strip()
        
        return {
            'type': 'analysis',
            'sql_query': sql_statement,
            'explanation': f"SQL analysis generated by Snowflake Cortex Analyst for: {query}",
            'executed': False,
            'execution_note': 'SQL generated by Cortex Analyst. Execute in Snowflake to get results.',
            'query_type': determine_query_type(sql_statement)
        }
        
    except Exception as e:
        logger.error(f"Error parsing analyst result: {e}")
        return {
            'type': 'analysis',
            'sql_query': str(result),
            'explanation': f"Analysis for: {query}",
            'executed': False,
            'error': str(e)
        }

def determine_query_type(sql: str) -> str:
    """Determine the type of SQL query"""
    sql_lower = sql.lower()
    if 'count(' in sql_lower and 'group by' in sql_lower:
        return 'aggregation'
    elif 'select distinct' in sql_lower:
        return 'distinct'
    elif 'count(' in sql_lower:
        return 'count'
    else:
        return 'select'


# Global MCP client instance
mcp_client = MCPClient()

@app.route('/')
def index():
    """Main MCP client interface"""
    return render_template('mcp_client.html')

@app.route('/api/tools')
def list_tools():
    """List available MCP tools"""
    try:
        logger.info("📋 Fetching MCP tools list...")
        tools = mcp_client.list_tools()
        
        return jsonify({
            'success': True,
            'tools': tools,
            'count': len(tools),
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"❌ Error fetching tools: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/api/search', methods=['POST'])
def search_documents():
    """Search SEC documents using policy-search tool"""
    try:
        data = request.get_json()
        query = data.get('query', '')
        limit = data.get('limit', 10)
        
        if not query:
            return jsonify({'success': False, 'error': 'Query is required'}), 400
        
        logger.info(f"🔍 Document search: '{query}' (limit: {limit})")
        
        # Call the search tool (configurable)
        result = mcp_client.call_tool(MCP_SEARCH_TOOL, {
            "query": query,
            "limit": limit
        })
        
        # Extract the actual content from MCP result
        documents = []
        if 'content' in result and isinstance(result['content'], list):
            for item in result['content']:
                if item.get('type') == 'text' and 'text' in item:
                    documents.append({
                        'CONTEXTUALIZED_CHUNK': item['text'],
                        'source': 'policy_search'
                    })
        
        return jsonify({
            'success': True,
            'results': documents,
            'query': query,
            'tool_used': MCP_SEARCH_TOOL,
            'raw_mcp_response': result,  # Full raw MCP response for debug mode
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"❌ Search error: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/api/analyze', methods=['POST'])
def analyze_data():
    """Analyze data using revenue-semantic-view tool"""
    try:
        data = request.get_json()
        message = data.get('message', '')
        
        if not message:
            return jsonify({'success': False, 'error': 'Message is required'}), 400
        
        logger.info(f"📊 Data analysis: '{message}'")
        
        # Call the analyst tool (configurable)
        result = mcp_client.call_tool(MCP_ANALYST_TOOL, {
            "message": message
        })
        
        # Parse the analyst result to extract SQL and execute it
        analysis_result = parse_analyst_result(result, message)
        
        return jsonify({
            'success': True,
            'results': analysis_result,
            'message': message,
            'tool_used': MCP_ANALYST_TOOL,
            'raw_mcp_response': result,  # Full raw MCP response for debug mode
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"❌ Analysis error: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/api/status')
def get_status():
    """Get MCP server connection status"""
    try:
        # Test connection by listing tools
        tools = mcp_client.list_tools()
        
        return jsonify({
            'connected': True,
            'server_url': MCP_SERVER_URL,
            'tools_available': len(tools),
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        return jsonify({
            'connected': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

if __name__ == '__main__':
    logger.info("🚀 Starting Lightweight MCP Client")
    logger.info(f"📡 Connected to: {MCP_SERVER_URL}")
    app.run(host='0.0.0.0', port=5000, debug=True)
