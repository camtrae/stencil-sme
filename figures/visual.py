#!/usr/bin/env python3
"""
Stencil Performance Visualization Script
Comparing Intel Xeon Platinum 8358 vs Apple M4 with SME
Author: Performance Analysis Team
Date: 2024
"""

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Patch
import warnings
warnings.filterwarnings('ignore')

def setup_plot_style():
    """Set up the plot style and color scheme"""
    # Set scientific paper style
    plt.style.use('seaborn-v0_8-whitegrid')
    
    # Morandi color palette
    colors = {
        'intel_primary': '#7B9AAF',    # Dusty blue
        'intel_light': '#A5C0CE',      # Light dusty blue
        'apple_primary': '#B5796F',    # Muted terracotta
        'apple_light': '#D4A5A5',      # Light terracotta
        'grid': '#E8E8E8',             # Very light grey
        'text': '#5A5A5A',             # Soft dark grey
        'highlight': '#C4A57B',        # Sandy beige
        'baseline': '#9B9B9B',         # Neutral grey
    }
    
    # Configure fonts
    plt.rcParams.update({
        'font.family': 'serif',
        'font.serif': ['Times New Roman', 'DejaVu Serif'],
        'font.size': 10,
        'axes.labelsize': 11,
        'axes.titlesize': 12,
        'xtick.labelsize': 9,
        'ytick.labelsize': 9,
        'legend.fontsize': 9,
        'figure.titlesize': 14,
        'axes.linewidth': 1.2,
        'axes.edgecolor': colors['text'],
        'axes.spines.top': False,
        'axes.spines.right': False,
    })
    
    return colors

def load_data():
    """Load the performance data"""
    intel_data = {
        'methods': ['Baseline', 'im2row', 'Stencil2Row', 'Stencil2Row\nSIMD/SME', 'Stencil2Row\nOpenMP/SME-Tiles'],
        'time': [953.00, 936.20, 1860.75, 117.15, 61.55],
        'speedup': [1.00, 1.02, 0.51, 8.13, 15.48],
        'threads': [1, 1, 1, 1, 32]
    }
    
    apple_data = {
        'methods': ['Baseline', 'Im2Row GEMV', 'Stencil2Row Direct', 'SME Single Tile', 'SME 4-Tiles'],
        'time': [804.15, 457.70, 826.55, 15.40, 8.70],
        'speedup': [1.00, 1.76, 0.97, 52.22, 91.90],
        'threads': [1, 1, 1, 1, 1]
    }
    
    return intel_data, apple_data

def create_execution_time_plot(ax, intel_data, apple_data, colors):
    """Create the execution time comparison bar chart"""
    n_methods = len(intel_data['methods'])
    x = np.arange(n_methods)
    bar_width = 0.35
    
    # Intel bars
    intel_bars = []
    for i, (time, threads) in enumerate(zip(intel_data['time'], intel_data['threads'])):
        color = colors['intel_primary'] if threads > 1 else colors['intel_light']
        alpha = 0.85 if threads > 1 else 0.7
        edgecolor = colors['highlight'] if time == min(intel_data['time']) else 'white'
        linewidth = 2.5 if time == min(intel_data['time']) else 1.2
        
        bar = ax.bar(x[i] - bar_width/2, time, bar_width,
                     color=color, alpha=alpha, edgecolor=edgecolor, linewidth=linewidth)
        intel_bars.append(bar)
    
    # Apple bars
    apple_bars = []
    for i, time in enumerate(apple_data['time']):
        color = colors['apple_primary'] if time == min(apple_data['time']) else colors['apple_light']
        alpha = 0.85 if time == min(apple_data['time']) else 0.7
        edgecolor = colors['highlight'] if time == min(apple_data['time']) else 'white'
        linewidth = 2.5 if time == min(apple_data['time']) else 1.2
        
        bar = ax.bar(x[i] + bar_width/2, time, bar_width,
                     color=color, alpha=alpha, edgecolor=edgecolor, linewidth=linewidth)
        apple_bars.append(bar)
    
    # Value labels for best performers
    best_intel_idx = intel_data['time'].index(min(intel_data['time']))
    best_apple_idx = apple_data['time'].index(min(apple_data['time']))

    # Intel best time label - unified style with Apple
    intel_best_time = intel_data['time'][best_intel_idx]
    ax.text(x[best_intel_idx] - bar_width/2, intel_best_time + 9,
        f'{intel_best_time:.1f} μs', ha='center', va='bottom',
        fontsize=9, fontweight='bold', color=colors['intel_primary'],
        bbox=dict(boxstyle='round,pad=0.3', facecolor='white', 
                    alpha=0.9, edgecolor=colors['intel_primary'], linewidth=1))

    # Apple best time label - same style
    apple_best_time = apple_data['time'][best_apple_idx]
    ax.text(x[best_apple_idx] + bar_width/2, apple_best_time + 1.5,
        f'{apple_best_time:.1f} μs', ha='center', va='bottom',
        fontsize=9, fontweight='bold', color=colors['apple_primary'],
        bbox=dict(boxstyle='round,pad=0.3', facecolor='white', 
                    alpha=0.9, edgecolor=colors['apple_primary'], linewidth=1))
    
    # Configure axes
    ax.set_ylabel('Execution Time (μs)', fontweight='bold', color=colors['text'])
    ax.set_yscale('log')
    ax.set_ylim([5, 3000])
    ax.set_xticks(x)
    ax.set_xticklabels(intel_data['methods'], fontsize=9)
    ax.set_title('Execution Time Comparison', fontweight='bold', pad=15, color=colors['text'])
    ax.grid(True, alpha=0.3, linestyle='--', axis='y', color=colors['grid'])
    
    # Legend
    legend_elements = [
        Patch(facecolor=colors['intel_light'], alpha=0.7, label='Intel (1 thread)'),
        Patch(facecolor=colors['intel_primary'], alpha=0.85, label='Intel (32 threads)'),
        Patch(facecolor=colors['apple_light'], alpha=0.7, label='Apple M4 (1 thread)'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', frameon=True, 
             framealpha=0.95, fancybox=False, edgecolor=colors['grid'])
    
    # Performance summary
    perf_text = (f"Best Performance:\n"
                f"Intel: {intel_data['time'][best_intel_idx]:.1f} μs (32t)\n"
                f"Apple: {apple_data['time'][best_apple_idx]:.1f} μs (1t)\n"
                f"M4 Advantage: {intel_data['time'][best_intel_idx]/apple_data['time'][best_apple_idx]:.1f}×")
    ax.text(0.02, 0.98, perf_text, transform=ax.transAxes,
           fontsize=8.5, verticalalignment='top',
           bbox=dict(boxstyle='round,pad=0.5', facecolor='white', alpha=0.95, 
                    edgecolor=colors['text'], linewidth=1))

def create_speedup_plot(ax, intel_data, apple_data, colors):
    """Create the speedup factor line chart"""
    optimization_levels = np.arange(5)
    
    # Intel speedup line
    ax.plot(optimization_levels, intel_data['speedup'], 
           'o-', color=colors['intel_primary'], 
           linewidth=2.5, markersize=9, markeredgewidth=2,
           markeredgecolor='white', label='Intel Xeon Platinum 8358', 
           alpha=0.9, zorder=3)
    
    # Intel data labels
    for i, (x, y) in enumerate(zip(optimization_levels, intel_data['speedup'])):
        if i in [0, 2, 4]:
            ax.text(x, y * 1.15, f'{y:.1f}×', ha='center', va='bottom',
                   fontsize=8.5, color=colors['intel_primary'], fontweight='bold')
    
    # Apple speedup line
    ax.plot(optimization_levels, apple_data['speedup'],
           's-', color=colors['apple_primary'],
           linewidth=2.5, markersize=9, markeredgewidth=2,
           markeredgecolor='white', label='Apple M4 (SME)', 
           alpha=0.9, zorder=3)
    
    # Apple data labels
    for i, (x, y) in enumerate(zip(optimization_levels, apple_data['speedup'])):
        if i in [0, 3, 4]:
            offset_y = 0.85 if i == 4 else 1.15
            ax.text(x, y * offset_y, f'{y:.1f}×', ha='center', 
                   va='top' if i == 4 else 'bottom',
                   fontsize=8.5, color=colors['apple_primary'], fontweight='bold')
    
    # Baseline reference line
    ax.axhline(y=1.0, color=colors['baseline'], 
              linestyle='--', linewidth=1.5, alpha=0.5, label='Baseline (1.0×)', zorder=1)
    
    # Configure axes - Now using the same method names as the first plot
    ax.set_ylabel('Speedup Factor (×)', fontweight='bold', color=colors['text'])
    ax.set_yscale('log')
    ax.set_ylim([0.4, 150])
    ax.set_xlim([-0.3, 4.3])
    ax.set_xticks(optimization_levels)
    # Use the same method names as in the first plot for consistency
    ax.set_xticklabels(intel_data['methods'], fontsize=9)
    ax.set_title('Speedup Factor Analysis', fontweight='bold', pad=15, color=colors['text'])
    ax.legend(loc='upper left', frameon=True, framealpha=0.95, fontsize=9,
             fancybox=False, edgecolor=colors['grid'])
    ax.grid(True, alpha=0.3, linestyle='--', zorder=0, color=colors['grid'])
    
    # Speedup summary
    speedup_text = (f"Peak Speedup:\n"
                   f"Intel: {intel_data['speedup'][-1]:.1f}× (32t)\n"
                   f"Apple: {apple_data['speedup'][-1]:.1f}× (1t)\n"
                   f"Efficiency: {apple_data['speedup'][-1]/intel_data['speedup'][-1]:.1f}× better")
    ax.text(0.98, 0.02, speedup_text, transform=ax.transAxes,
           fontsize=8.5, verticalalignment='bottom', ha='right',
           bbox=dict(boxstyle='round,pad=0.5', facecolor='white', alpha=0.95,
                    edgecolor=colors['text'], linewidth=1))

def main():
    """Main function to create and save the visualization"""
    print("Starting visualization generation...")
    print("-" * 50)
    
    # Setup
    colors = setup_plot_style()
    intel_data, apple_data = load_data()
    
    # Create figure
    fig = plt.figure(figsize=(14, 6))
    
    # Create subplots
    ax1 = fig.add_subplot(1, 2, 1)
    ax2 = fig.add_subplot(1, 2, 2)
    
    # Generate plots
    create_execution_time_plot(ax1, intel_data, apple_data, colors)
    create_speedup_plot(ax2, intel_data, apple_data, colors)
    
    # Overall title and footer
    fig.suptitle('15×15 Stencil Computation Performance Analysis', 
                fontsize=15, fontweight='bold', y=1.02, color=colors['text'])
    
    fig.text(0.5, 0.01, 
            'Intel Xeon Platinum 8358 (32 cores @ 2.6 GHz) vs Apple M4 (Single P-core @ 4.4 GHz)',
            ha='center', fontsize=9, style='italic', color=colors['text'], alpha=0.8)
    
    # Adjust layout
    plt.tight_layout()
    plt.subplots_adjust(bottom=0.08, top=0.94)
    
    # Save in multiple formats
    output_formats = {
        'png': {'dpi': 300, 'desc': 'GitHub/Web display'},
        'pdf': {'dpi': None, 'desc': 'LaTeX/Papers'},
        'svg': {'dpi': None, 'desc': 'Vector graphics'},
    }
    
    print("\nSaving files...")
    print("-" * 50)
    
    for fmt, settings in output_formats.items():
        filename = f'stencil_performance_comparison.{fmt}'
        plt.savefig(filename, dpi=settings['dpi'], 
                   bbox_inches='tight', facecolor='white')
        print(f'✓ Saved {filename} - {settings["desc"]}')
    
    # High-resolution version
    plt.savefig('performance_analysis.png', dpi=600, 
               bbox_inches='tight', facecolor='white')
    print('✓ Saved stencil_performance_comparison_hires.png - Publication quality (600 DPI)')
    
    # Display summary
    print("\n" + "=" * 50)
    print("📊 Visualization Complete!")
    print("=" * 50)
    print(f"Key Findings:")
    print(f"  • Intel Best: {min(intel_data['time']):.1f} μs (32 threads)")
    print(f"  • Apple Best: {min(apple_data['time']):.1f} μs (1 thread)")
    print(f"  • Performance Advantage: {min(intel_data['time'])/min(apple_data['time']):.1f}× faster")
    print(f"  • Thread Efficiency: 32× fewer threads")
    print("=" * 50)
    
    # Show plot
    plt.show()

if __name__ == "__main__":
    main()