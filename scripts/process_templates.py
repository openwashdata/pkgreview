#!/usr/bin/env python3
"""
Template processor for R package review system.
Replaces placeholders in template files with values from config.yml
"""

import os
import re
import yaml
import shutil
from pathlib import Path


def load_config(config_file='config.yml'):
    """Load configuration from YAML file."""
    with open(config_file, 'r') as f:
        return yaml.safe_load(f)


def get_replacement_values(config):
    """Generate all replacement values from config."""
    replacements = {
        # Organization
        'ORGANIZATION_NAME': config['organization']['name'],
        'GITHUB_URL': config['organization']['github_url'],
        
        # Template
        'TEMPLATE_PACKAGE': config['template']['package'],
        'CITATION_FUNCTION': config['template']['citation_function'],
        
        # License and style
        'LICENSE': config['standards']['license'],
        'STYLE_GUIDE': config['standards']['style_guide'],
        'INDENT_SIZE': str(config['standards']['indent_size']),
        'MAX_LINE_LENGTH': str(config['standards']['max_line_length']),
    }
    
    # Analytics (conditional)
    if config['analytics']['enabled']:
        replacements.update({
            'ANALYTICS_ENABLED': 'true',
            'ANALYTICS_TYPE': config['analytics']['type'],
            'ANALYTICS_DOMAIN': config['analytics']['domain'],
            'ANALYTICS_SCRIPT': config['analytics']['script'],
        })
    else:
        replacements['ANALYTICS_ENABLED'] = 'false'
    
    # Funding (conditional)
    if config['funding']['enabled']:
        replacements['FUNDING_ENABLED'] = 'true'
        if config['funding']['use_default']:
            replacements['FUNDING_TEXT'] = config['funding']['default_text']
        else:
            replacements['FUNDING_TEXT'] = config['funding']['custom_text']
    else:
        replacements['FUNDING_ENABLED'] = 'false'
    
    return replacements


def process_template(template_content, replacements):
    """Replace placeholders in template content."""
    # Simple placeholder replacement
    for key, value in replacements.items():
        template_content = template_content.replace(f'{{{{{key}}}}}', str(value))
    
    # Handle conditional blocks
    template_content = process_conditionals(template_content, replacements)
    
    return template_content


def process_conditionals(content, replacements):
    """Process conditional blocks in templates."""
    # Pattern for conditional blocks: {{#if VARIABLE}}...{{/if}}
    pattern = r'{{#if\s+(\w+)}}(.*?){{/if}}'
    
    def replace_conditional(match):
        condition = match.group(1)
        block_content = match.group(2)
        
        # Check if condition is true
        if condition in replacements and replacements[condition] in ['true', True]:
            return block_content
        else:
            return ''
    
    # Process all conditionals
    content = re.sub(pattern, replace_conditional, content, flags=re.DOTALL)
    
    return content


def process_file(template_file, output_file, replacements):
    """Process a single template file."""
    print(f"Processing {template_file} -> {output_file}")
    
    with open(template_file, 'r') as f:
        template_content = f.read()
    
    processed_content = process_template(template_content, replacements)
    
    # Create output directory if needed
    output_dir = os.path.dirname(output_file)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)
    
    with open(output_file, 'w') as f:
        f.write(processed_content)


def main():
    """Main processing function."""
    # Check if config.yml exists
    if not os.path.exists('config.yml'):
        print("Error: config.yml not found. Run /setup-review first.")
        return 1
    
    # Load configuration
    config = load_config()
    replacements = get_replacement_values(config)
    
    print("Processing templates with configuration:")
    print(f"  Organization: {config['organization']['name']}")
    print(f"  Template package: {config['template']['package']}")
    print(f"  Analytics: {'enabled' if config['analytics']['enabled'] else 'disabled'}")
    print(f"  Funding: {'enabled' if config['funding']['enabled'] else 'disabled'}")
    print()
    
    # Process CLAUDE.md template
    if os.path.exists('templates/CLAUDE.md.template'):
        process_file('templates/CLAUDE.md.template', 'CLAUDE.md', replacements)
    
    # Process command templates
    templates_commands_dir = Path('templates/commands')
    commands_dir = Path('commands')
    
    for template_file in templates_commands_dir.glob('*.md.template'):
        output_file = commands_dir / template_file.stem
        process_file(str(template_file), str(output_file), replacements)
    
    # If running in pkgreview repo, copy templates to working directory
    if os.path.basename(os.getcwd()) == 'pkgreview':
        print("\nNote: You appear to be in the pkgreview repository.")
        print("Template files have been processed in place.")
        print("To use these in your package, copy the generated files to your package directory.")
    
    print("\n✅ Template processing complete!")
    print("\nGenerated files:")
    print("  - CLAUDE.md (customized review guide)")
    print("  - commands/*.md (customized command files)")
    print("\nYour package review system is ready to use!")
    print("Start with: /review-package [package-name]")
    
    return 0


if __name__ == '__main__':
    exit(main())