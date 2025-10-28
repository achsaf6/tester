# BFF (Backend For Frontend) Template

This project is a Backend For Frontend (BFF) template that provides a structured starting point for building backend services that directly support frontend applications. The BFF pattern is designed to optimize the backend API for specific frontend requirements.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

### Container Runtime and Cloud Tools
- Colima is required for running containers on macOS:
  ```bash
  brew install colima
  colima start
  ```
- Docker is required for containerization:
  ```bash
  brew install docker
  ```
- Google Cloud SDK (required for admin mode):
  ```bash
  brew install google-cloud-sdk
  gcloud init
  gcloud auth configure-docker
  ```
- For more information, visit:
  - [Colima's documentation](https://github.com/abiosoft/colima)
  - [Google Cloud SDK documentation](https://cloud.google.com/sdk/docs)

### Python
- Python 3.8 or higher
- To check your Python version:
  ```bash
  python --version
  ```
- Install Python from [python.org](https://www.python.org/downloads/)

### Poetry (Python Dependency Management)
- Poetry is required for managing Python dependencies
- Install Poetry by running:
  ```bash
  curl -sSL https://install.python-poetry.org | python3 -
  ```
- Verify installation:
  ```bash
  poetry --version
  ```
- For more information, visit [Poetry's documentation](https://python-poetry.org/docs/)

### Node.js and npm
- Node.js 14.x or higher is required for the React frontend
- To check your Node.js version:
  ```bash
  node --version
  npm --version
  ```
- Install Node.js from [nodejs.org](https://nodejs.org/)

### GitHub CLI (gh)
- GitHub CLI is required for managing GitHub secrets and interacting with repositories
- Install GitHub CLI using Homebrew:
  ```bash
  brew install gh
  ```
- Authenticate with GitHub:
  ```bash
  gh auth login
  ```
- Follow the interactive prompts to complete authentication
- For more information, visit [GitHub CLI documentation](https://cli.github.com/)

## Project Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/achsaf6/bff-template
   cd bff-template
   ```

2. Initialize the project:
   ```bash
   make init
   ```
   This command will run the initialization script that:
   - Prompts for deployment type:
     - `local` (default): Sets up local development environment
     - `admin`: Sets up full deployment with GCP service accounts and Docker configuration
   - Prompts for region (default: europe-west4)
   - Updates project name in configuration files
   - Creates and sets up a new React frontend application
   - Installs Python backend dependencies using Poetry
   - Configures CI/CD workflow settings
   
   If running in `admin` mode, it will also:
   - Activate CI/CD workflow
   - Build and push Docker container to Google Container Registry
   - Create and configure GCP service account with necessary permissions
   - Set up GitHub secrets for deployment

3. After initialization, set your Python interpreter to the path shown in the terminal output.
   Note: The init script can only be run once as it self-disables after completion.

## Project Structure

```
bff-template/
├── backend/         # Backend service directory
│   └── main.py     # Main application entry point
├── frontend/        # React frontend application
├── makefile        # Build automation
├── poetry.lock     # Lock file for dependencies
└── pyproject.toml  # Python project configuration
```

## Development

Available make commands:
- `make init` - Initialize the project (first-time setup)
- `make dev` - Run both frontend and backend in development mode
- `make local` - Run backend only
- `make update` - Commit and push changes
- `make test` - Run tests (customizable)
- `make deploy` - Deploy to Google Cloud Run

## Deployment

The project includes a comprehensive deployment manager that handles:
- Docker image building and pushing to Google Container Registry
- Cloud Run deployment
- Service account creation and configuration
- GitHub secrets setup
- CI/CD workflow configuration

### Initial Deployment

To deploy your application to Google Cloud Run:

```bash
make deploy
```

This will:
1. Update CI/CD configuration with project-specific values
2. Build and push Docker container to GCR
3. Deploy the container to Cloud Run
4. Create a service account with necessary permissions
5. Configure GitHub secrets for automatic deployments
6. Enable the CI/CD workflow

After successful deployment, any commits to the `main` branch will automatically:
1. Build a new Docker image
2. Push it to Google Container Registry
3. Deploy the updated container to Cloud Run

### Managing GitHub Secrets

The deployment system automatically sets up the service account credentials as a GitHub secret. You can add additional secrets (API keys, tokens, etc.) using the manager CLI:

```bash
# Add a secret interactively (will prompt for value)
python -m manager secrets add --name API_KEY

# Add a secret with a value
python -m manager secrets add --name API_KEY --value abc123

# Add a secret from a file
python -m manager secrets add --name API_KEY --file key.txt
```

To use secrets in your application, add them to the Cloud Run deployment in `.github/workflows/cicd.yaml`:

```yaml
- name: Deploy to Cloud Run
  run: |
    gcloud run deploy $SERVICE_NAME \
      --image ${{ env.DOCKER_IMAGE_URL }}:latest \
      --platform managed \
      --region ${{ env.CONTAINER_REGION }} \
      --port 80 \
      --set-env-vars="API_KEY=${{ secrets.API_KEY }}"
```

### Manager CLI Commands

The project includes a comprehensive CLI for managing deployments:

```bash
# Deployment
python -m manager deploy                    # Deploy to GCP
python -m manager deploy --region us-east1  # Deploy to specific region

# Status and Monitoring
python -m manager status                    # Show project status
python -m manager status -v                 # Show detailed status
python -m manager history                   # Show operation history

# Configuration
python -m manager config --list             # List all config values
python -m manager config --get region       # Get a config value
python -m manager config --set key=value    # Set a config value

# Service Account Management
python -m manager service-account create                    # Create service account
python -m manager service-account delete                    # Delete service account
python -m manager service-account add-permissions           # Add default permissions
python -m manager service-account add-permissions --roles roles/run.admin
python -m manager service-account remove-permissions        # Remove permissions

# GitHub Secrets
python -m manager secrets add --name SECRET_NAME            # Add/update a secret

# Cleanup
python -m manager clean                     # Clean up all resources
python -m manager clean --skip-local        # Clean GCP/GitHub but keep local files
```

### CI/CD Workflow

The project includes a GitHub Actions workflow (`.github/workflows/cicd.yaml`) that automatically deploys on push to `main`. The workflow:

1. Builds the Docker image for linux/amd64 platform
2. Pushes to Google Container Registry (gcr.io)
3. Deploys to Cloud Run with the configured settings
4. Uses cached Docker layers for faster builds

The workflow is automatically configured and enabled during the deployment process.

## Managing Dependencies

### Adding Frontend Libraries (npm)

To add a new library to the React frontend:

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install the package:
   ```bash
   npm install <package-name>
   ```

3. For development-only dependencies:
   ```bash
   npm install --save-dev <package-name>
   ```

4. The package will be automatically added to `package.json` and `package-lock.json`

Example:
```bash
npm install axios           # Add axios for HTTP requests
npm install --save-dev jest # Add jest as a dev dependency
```

### Adding Python Modules (uv)

To add a new Python module to the backend:

1. Make sure you're in the project root directory

2. Add a package:
   ```bash
   uv add <package-name>
   ```

3. For development-only dependencies:
   ```bash
   uv add --dev <package-name>
   ```

4. The package will be automatically added to `pyproject.toml` and `uv.lock`

Example:
```bash
uv add requests         # Add requests for HTTP calls
uv add --dev pytest     # Add pytest as a dev dependency
```

For more information:
- [npm documentation](https://docs.npmjs.com/)
- [uv documentation](https://github.com/astral-sh/uv)

## Contributing

1. Create a new branch for your feature
2. Make your changes
3. Submit a pull request

## License

[Add your license information here]
