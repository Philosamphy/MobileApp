# CI/CD Automatic Upload to GitHub 1B Folder

This project contains CI/CD workflows to automatically upload the contents of the local `test` folder to the `1B` folder in the GitHub repository `Philosamphy/MobileApp`.

## Workflow Files

The project includes three different GitHub Actions workflows:

### 1. `upload-basic.yml` (Recommended)
- Simplest workflow
- Directly copies test folder contents to 1B folder
- Automatically commits and pushes changes

### 2. `upload-to-1b.yml`
- Uses Python and PyGithub library
- More complex file processing logic
- Supports file updates and creation

## How to Use

### Method 1: Push to main branch
1. Place files in the `test` folder
2. Commit and push to main branch
3. Workflow will automatically trigger and upload files to 1B folder

### Method 2: Manual trigger
1. Go to GitHub repository page
2. Click "Actions" tab
3. Select the appropriate workflow
4. Click "Run workflow" to trigger manually

## Trigger Conditions

Workflows will trigger under the following conditions:
- Push to main branch with changes in test folder
- Manual trigger (workflow_dispatch)

## Permission Requirements

Ensure the repository has the following permissions:
- `contents: write` - For creating and updating files
- `actions: read` - For running workflows

## Important Notes

1. Workflow will automatically create 1B folder if it doesn't exist
2. Existing files will be overwritten
3. All changes will be automatically committed to repository
4. Workflow runs on Ubuntu latest version

## Troubleshooting

If workflow fails, check:
1. Repository permission settings
2. Whether test folder exists
3. If GitHub Actions is enabled
4. Network connectivity 