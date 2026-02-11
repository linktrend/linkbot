---
name: typescript-coding
description: TypeScript and JavaScript coding skill for web development, MCP server creation, Node.js applications, and frontend development. Includes React, Next.js, and modern tooling.
license: MIT
source: Multiple sources (GitHub MCP Server, VoltAgent, Microsoft Skills)
version: 1.0.0
last_updated: 2026-02-09
supports_subagent: true
environment_variables:
  - name: GITHUB_TOKEN
    description: GitHub personal access token for repository operations (optional)
    required: false
  - name: NODE_ENV
    description: Node environment (development, production)
    required: false
    default: development
---

# TypeScript/JavaScript Coding Skill

## Overview

This skill provides comprehensive TypeScript and JavaScript development capabilities:
- TypeScript/JavaScript code generation
- React and Next.js development
- MCP server creation
- Node.js backend development
- GitHub repository operations
- Modern tooling (ESLint, Prettier, TypeScript compiler)

## Installation

### 1. Install Node.js and TypeScript

```bash
# Install Node.js (v22+ recommended)
# Download from https://nodejs.org

# Verify installation
node --version  # Should be ≥22
npm --version

# Install TypeScript globally
npm install -g typescript ts-node

# Install modern tooling
npm install -g tsx prettier eslint
```

### 2. Install GitHub MCP Server (Optional)

```bash
# For GitHub integration
npm install -g @github/github-mcp-server

# Configure in ~/.openclaw/config.json
```

### 3. Create TypeScript Project Template

```bash
# Quick setup with create-mcp-ts
npm init mcp-ts my-typescript-project

# Or manual setup
mkdir my-project && cd my-project
npm init -y
npm install --save-dev typescript @types/node
npx tsc --init
```

## Key Features

### Code Generation
- Generate TypeScript/JavaScript applications
- Create React components and hooks
- Build Next.js pages and API routes
- Develop Node.js servers and APIs

### MCP Server Development
- Create custom MCP servers in TypeScript
- Zero-configuration setup with create-mcp-ts
- Auto-configuration for Cursor, Windsurf, Claude Desktop
- Built-in TypeScript support

### GitHub Operations (via GitHub MCP Server)
- Create and manage issues
- Handle pull requests
- Access repository information
- Search code and manage projects

### Modern Frameworks
- **React**: Component-based UI development
- **Next.js**: Full-stack React framework
- **Express**: Web server framework
- **Fastify**: High-performance server

## Usage Examples

### Create MCP Server in TypeScript

```bash
# Zero-configuration setup
npm init mcp-ts weather-server

# Automatically creates:
# - TypeScript configuration
# - Development environment
# - Build setup
# - MCP client configurations
```

### Generate React Component

```typescript
// Create a modern React component
import React, { useState, useEffect } from 'react';

interface TaskProps {
  id: string;
  title: string;
  completed: boolean;
}

export const TaskItem: React.FC<TaskProps> = ({ id, title, completed }) => {
  const [isComplete, setIsComplete] = useState(completed);

  const toggleComplete = () => {
    setIsComplete(!isComplete);
    // API call to update task
  };

  return (
    <div className="task-item">
      <input
        type="checkbox"
        checked={isComplete}
        onChange={toggleComplete}
      />
      <span style={{ textDecoration: isComplete ? 'line-through' : 'none' }}>
        {title}
      </span>
    </div>
  );
};
```

### Create Next.js API Route

```typescript
// pages/api/tasks/[id].ts
import type { NextApiRequest, NextApiResponse } from 'next';

interface Task {
  id: string;
  title: string;
  completed: boolean;
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<Task | { error: string }>
) {
  const { id } = req.query;

  if (req.method === 'GET') {
    // Fetch task from database
    const task = await getTaskById(id as string);
    return res.status(200).json(task);
  }

  if (req.method === 'PUT') {
    // Update task
    const updated = await updateTask(id as string, req.body);
    return res.status(200).json(updated);
  }

  res.status(405).json({ error: 'Method not allowed' });
}
```

### Build MCP Server with GitHub Integration

```typescript
// server.ts - MCP server with GitHub operations
import { McpServer } from '@anthropic/mcp-sdk';
import { Octokit } from '@octokit/rest';

const octokit = new Octokit({
  auth: process.env.GITHUB_TOKEN
});

const server = new McpServer({
  name: 'github-helper',
  version: '1.0.0'
});

// Tool: Create GitHub issue
server.tool({
  name: 'create_issue',
  description: 'Create a new GitHub issue',
  parameters: {
    type: 'object',
    properties: {
      owner: { type: 'string' },
      repo: { type: 'string' },
      title: { type: 'string' },
      body: { type: 'string' }
    },
    required: ['owner', 'repo', 'title']
  },
  async handler(params) {
    const { owner, repo, title, body } = params;
    
    const { data } = await octokit.issues.create({
      owner,
      repo,
      title,
      body: body || ''
    });

    return {
      success: true,
      issue_number: data.number,
      url: data.html_url
    };
  }
});

// Start server
server.start();
```

### Generate Node.js Express Server

```typescript
// server.ts - Express API server
import express, { Request, Response } from 'express';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.get('/api/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.post('/api/tasks', async (req: Request, res: Response) => {
  try {
    const { title, description } = req.body;
    // Save to database
    res.status(201).json({ id: 'task-123', title, description });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create task' });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
```

## Sub-Agent Execution Support

**YES** - This skill strongly supports sub-agent execution:

### Multi-Agent Development Patterns

1. **Frontend Agent**: React component development
2. **Backend Agent**: API route creation
3. **Testing Agent**: Jest/Vitest test generation
4. **DevOps Agent**: Docker and deployment configs
5. **Documentation Agent**: TypeDoc and README generation

### Example Multi-Agent Workflow

```typescript
// Agent 1: Component Generation
generateReactComponent('TaskList', {
  props: ['tasks', 'onComplete'],
  hooks: ['useState', 'useEffect']
});

// Agent 2: API Route Creation
generateApiRoute('/api/tasks', {
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  database: 'postgresql'
});

// Agent 3: Test Generation
generateTests('TaskList.test.tsx', {
  framework: 'vitest',
  coverage: true
});

// Agent 4: Documentation
generateDocs('README.md', {
  includeApi: true,
  includeExamples: true
});
```

## Configuration

### Environment Variables

```bash
# Optional GitHub integration
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxx

# Node environment
export NODE_ENV=development

# API configuration
export API_BASE_URL=http://localhost:3000
export DATABASE_URL=postgresql://localhost/mydb
```

### OpenClaw Configuration

Add to `~/.openclaw/config.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["@github/github-mcp-server"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  },
  "skills": {
    "typescript-coding": {
      "model": "claude-3-5-haiku-20241022",
      "enabled": true,
      "config": {
        "typescript_version": "5.x",
        "framework": "next.js",
        "testing": "vitest"
      }
    }
  }
}
```

### TypeScript Configuration (tsconfig.json)

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

## Best Practices

### TypeScript
- Use strict mode
- Define interfaces for all data structures
- Avoid `any` type
- Use enums for constants
- Leverage utility types (Partial, Pick, Omit)

### React
- Use functional components with hooks
- Implement proper error boundaries
- Memoize expensive computations
- Use React.memo for performance
- Follow React 19 best practices

### Next.js
- Use App Router (not Pages Router)
- Implement proper SEO meta tags
- Optimize images with next/image
- Use server components where possible
- Implement proper caching strategies

### MCP Servers
- Validate all tool parameters
- Implement proper error handling
- Use TypeScript for type safety
- Document tools with clear descriptions
- Test with MCP inspector

## Security Best Practices

1. **Environment Variables**: Never commit secrets to git
2. **Input Validation**: Validate all user inputs
3. **CORS Configuration**: Restrict allowed origins
4. **Rate Limiting**: Implement API rate limits
5. **Authentication**: Use JWT or OAuth for APIs
6. **Dependency Scanning**: Use `npm audit` regularly

## Performance Considerations

- **Bundle Size**: Use tree-shaking and code splitting
- **Server-Side Rendering**: Leverage Next.js SSR/SSG
- **Caching**: Implement Redis or in-memory caching
- **Database**: Use connection pooling
- **CDN**: Serve static assets via CDN

## Troubleshooting

### TypeScript Errors

```bash
# Clear TypeScript cache
rm -rf node_modules/.cache

# Regenerate types
npx tsc --noEmit

# Check for type errors
npx tsc --noEmit --watch
```

### Build Failures

```bash
# Clean build
rm -rf dist node_modules package-lock.json
npm install
npm run build
```

### GitHub MCP Server Issues

```bash
# Verify GitHub token
gh auth status

# Test MCP server
npx @github/github-mcp-server --test
```

## Integration with OpenClaw Model Routing

```json
{
  "skills": {
    "typescript-coding": {
      "model": "claude-3-5-haiku-20241022",
      "reason": "Cost-effective for standard code generation",
      "fallback": "claude-3-5-sonnet-20241022"
    },
    "typescript-coding:complex": {
      "model": "claude-3-5-sonnet-20241022",
      "reason": "Better for complex architecture decisions"
    }
  }
}
```

## Source Repositories

- **GitHub MCP Server**: https://github.com/github/github-mcp-server
- **create-mcp-ts**: https://github.com/stephencme/create-mcp-ts
- **TypeScript**: https://github.com/microsoft/TypeScript
- **Next.js**: https://github.com/vercel/next.js

## Additional Resources

- TypeScript Handbook: https://www.typescriptlang.org/docs/
- React Documentation: https://react.dev
- Next.js Documentation: https://nextjs.org/docs
- MCP Specification: https://modelcontextprotocol.io
- GitHub MCP Guide: https://docs.github.com/en/copilot/using-github-copilot/using-model-context-protocol
