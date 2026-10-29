# GitHub Pages Setup Instructions

The repository is now configured for GitHub Pages deployment. Follow these steps to enable it:

## 1. Enable GitHub Pages in Repository Settings
1. Go to your GitHub repository: https://github.com/MrSmokeMaker/Eldertree
2. Click on **Settings** tab
3. Scroll down to **Pages** section in the left sidebar
4. Under **Source**, select **GitHub Actions**
5. The workflow will automatically deploy to GitHub Pages

## 2. First Deployment
The first deployment will trigger automatically after pushing the workflow file. You can:
1. Check the Actions tab: https://github.com/MrSmokeMaker/Eldertree/actions
2. Look for the "Deploy to GitHub Pages" workflow
3. Wait for it to complete (build may take 5-10 minutes)

## 3. Live URL
Once deployed, your app will be available at:
**https://mrsmokemaker.github.io/Eldertree/**

## 4. Manual Deployment
If you want to trigger a deployment manually:
1. Go to **Actions** tab
2. Select **Deploy to GitHub Pages** workflow
3. Click **Run workflow**
4. Select **main** branch and run

## 5. Testing Locally
To test the web build locally:
1. Run `build_web.bat` (Windows) or create similar script for other OS
2. The built files will be in `build/web/`
3. Serve them locally with a web server:
   ```bash
   # Using Python
   python -m http.server 8000 --directory build/web
   
   # Or using Node.js
   npx serve build/web
   ```

## 6. Custom Domain (Optional)
If you want to use a custom domain:
1. Go to **Settings > Pages**
2. Under **Custom domain**, enter your domain
3. Follow the DNS configuration instructions

## 7. Troubleshooting
- **Build fails**: Check Flutter version compatibility
- **404 errors**: Ensure `404.html` is present and base-href is correct
- **Assets not loading**: Verify asset paths in `pubspec.yaml`
- **Workflow not running**: Check repository permissions and workflow file syntax

## 8. Notes
- The app uses `canvaskit` renderer for better performance
- Base href is set to `/Eldertree/` for proper routing
- `.nojekyll` file prevents Jekyll processing
- 404.html handles SPA routing for direct URL access

## 9. Support
For issues with GitHub Pages deployment, check:
- GitHub Actions logs
- Flutter web build output
- Repository settings for Pages configuration