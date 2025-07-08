# setup-review

**Description**: Configure the R package review system for your organization by setting up necessary parameters and generating customized templates.

**Usage**: `/setup-review`

**Parameters**: None (interactive setup)

---

When the user types `/setup-review`, execute the following:

## 🔧 Package Review System Setup

Welcome! Let's configure the R package review system for your organization. I'll ask you a few questions to customize the review process.

### 1. Organization Information

**GitHub Organization/Username**: 
Please provide your GitHub organization name or username (e.g., 'openwashdata', 'myorg'):
> *[Wait for user input]*

### 2. Template Package

**R Package Template Tool**: 
Which R package do you use to create package templates? (default: washr)
> *[Wait for user input or press Enter for default]*

**Citation Update Function**:
What function do you use to update citations? (default: washr::update_citation)
> *[Wait for user input or press Enter for default]*

### 3. Analytics Configuration

**Enable Analytics?** (yes/no, default: yes)
> *[Wait for user input]*

{{#if analytics-enabled}}
**Analytics Provider**: 
Which analytics provider do you use? (plausible/google/matomo/other, default: plausible)
> *[Wait for user input]*

**Analytics Domain**:
What's your analytics domain? (default: {{organization-name}}.github.io)
> *[Wait for user input or press Enter for default]*

**Analytics Script URL**:
What's the full URL for your analytics script? (default: https://plausible.io/js/script.js)
> *[Wait for user input or press Enter for default]*
{{/if}}

### 4. Funding Acknowledgment

**Include Funding Section?** (yes/no, default: yes)
> *[Wait for user input]*

{{#if funding-enabled}}
**Use Default ETH ORD Funding Text?** (yes/no, default: yes)

The default text is:
> "This project was funded by the [Open Research Data Program of the ETH Board](https://ethrat.ch/en/eth-domain/open-research-data/)."

> *[Wait for user input]*

{{#if custom-funding}}
**Custom Funding Text**:
Please provide your custom funding acknowledgment text:
> *[Wait for user input]*
{{/if}}
{{/if}}

### 5. Review Configuration

**License for Data Packages** (default: CC BY 4.0):
> *[Wait for user input or press Enter for default]*

**Code Style Guide** (default: tidyverse):
> *[Wait for user input or press Enter for default]*

### 📝 Configuration Summary

Based on your inputs, here's your configuration:

```yaml
organization:
  name: "{{organization_name}}"
  github_url: "https://github.com/{{organization_name}}"
  
template:
  package: "{{template_package}}"
  citation_function: "{{citation_function}}"
  
analytics:
  enabled: {{analytics_enabled}}
{{#if analytics_enabled}}
  type: "{{analytics_type}}"
  domain: "{{analytics_domain}}"
  script: "{{analytics_script}}"
{{/if}}
  
funding:
  enabled: {{funding_enabled}}
{{#if funding_enabled}}
  use_default: {{use_default_funding}}
  {{#if use_default_funding}}
  default_text: "This project was funded by the [Open Research Data Program of the ETH Board](https://ethrat.ch/en/eth-domain/open-research-data/)."
  {{else}}
  custom_text: "{{custom_funding_text}}"
  {{/if}}
{{/if}}
  
standards:
  license: "{{license}}"
  style_guide: "{{style_guide}}"
```

### 🚀 Generating Custom Files

Now I'll generate your customized review system files...

```bash
# Create config.yml
cat > config.yml << 'EOF'
{{config_content}}
EOF

# Process templates
python3 scripts/process_templates.py

echo "✅ Setup complete! Your package review system is ready to use."
```

### ✅ Setup Complete!

Your package review system has been configured successfully. Here's what was created:

**Configuration Files:**
- `config.yml` - Your organization's settings
- `CLAUDE.md` - Customized review guide
- `commands/*.md` - Customized command files

**Next Steps:**
1. Review the generated `config.yml` file
2. Start your first package review with `/review-package [package-name]`
3. Check available commands with `/help`

**Available Commands:**
- `/review-package [package-name]` - Start a new package review
- `/review-issue [number]` - Work on a specific review issue
- `/create-next-issue` - Create the next issue in sequence
- `/review-status` - Check current review progress
- `/create-release [version]` - Create a new package release

### 📚 Documentation

For more information about the review process:
- Review workflow details are in `CLAUDE.md`
- Command documentation is in `commands/README.md`
- Visit {{organization_name}}/pkgreview for updates

---

## Error Handling

If configuration fails:
❌ Failed to create configuration files.

Please check:
1. You have write permissions in the current directory
2. Python 3 is installed (for template processing)
3. All required inputs were provided

You can manually create `config.yml` using the template above.

If templates already exist:
⚠️ Configuration files already exist.

Would you like to:
1. Overwrite existing configuration (type "overwrite")
2. Create backup and continue (type "backup")
3. Cancel setup (type "cancel")