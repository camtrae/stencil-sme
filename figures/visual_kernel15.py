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
    
    colors = {
        'intel_primary': '#045DB7',    # PPT模板蓝（更浅的学术蓝）
        'intel_light': '#7FA8FF',      # 浅蓝色
        'apple_primary': '#6A178B',    # PPT模板紫（深紫色）
        'apple_light': '#B580C5',      # 浅紫色
        'grid': '#E8E8E8',             # Very light grey
        'text': '#333333',             # 深灰色（更适合科研出版）
        'highlight': '#E74C3C',        # 强调色（不再使用）
        'baseline': '#7F7F7F',         # 中性灰
    }
    
    # Configure fonts - INCREASED SIZES
    plt.rcParams.update({
        'font.family': 'serif',
        'font.serif': ['Times New Roman', 'DejaVu Serif'],
        'font.size': 14,              
        'axes.labelsize': 15,          
        'axes.titlesize': 16,          
        'xtick.labelsize': 12,         
        'ytick.labelsize': 12,         
        'legend.fontsize': 12,         
        'figure.titlesize': 18,        
        'axes.linewidth': 1.5,         
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
        # 使用学术蓝色
        color = colors['intel_primary']
        alpha = 0.9  # 提高不透明度，让颜色更饱满
        # 移除特殊边框高亮，所有柱子都使用白色边框
        edgecolor = 'white'
        linewidth = 1.5
        
        bar = ax.bar(x[i] - bar_width/2, time, bar_width,
                     color=color, alpha=alpha, edgecolor=edgecolor, linewidth=linewidth)
        intel_bars.append(bar)
        
        # 添加Intel数据标签在柱子上方
        if time < 100:  # 对于较小的值，直接在上方
            offset = time * 0.15
        elif time < 1000:  # 中等值
            offset = time * 0.08
        else:  # 较大的值
            offset = time * 0.05
        
        ax.text(x[i] - bar_width/2, time + offset, f'{time:.1f}',
               ha='center', va='bottom', fontsize=14, fontweight='bold',
               color=colors['intel_primary'])
    
    # Apple bars
    apple_bars = []
    for i, time in enumerate(apple_data['time']):
        # 使用学术金黄色
        color = colors['apple_primary']
        alpha = 0.9  # 提高不透明度，让颜色更饱满
        # 移除特殊边框高亮，所有柱子都使用白色边框
        edgecolor = 'white'
        linewidth = 1.5
        
        bar = ax.bar(x[i] + bar_width/2, time, bar_width,
                     color=color, alpha=alpha, edgecolor=edgecolor, linewidth=linewidth)
        apple_bars.append(bar)
        
        # 添加Apple数据标签在柱子上方
        if time < 100:  # 对于较小的值
            offset = time * 0.15
        elif time < 1000:  # 中等值
            offset = time * 0.08
        else:  # 较大的值
            offset = time * 0.05
            
        ax.text(x[i] + bar_width/2, time + offset, f'{time:.1f}',
               ha='center', va='bottom', fontsize=14, fontweight='bold',
               color=colors['apple_primary'])
    
    # Configure axes
    ax.set_ylabel('Execution Time (μs)', fontweight='bold', color=colors['text'])
    ax.set_yscale('log')
    ax.set_ylim([5, 3000])
    ax.set_xticks(x)
    ax.set_xticklabels(intel_data['methods'], fontsize=14)
    ax.set_title('Execution Time Comparison', fontweight='bold', pad=15, color=colors['text'])
    ax.grid(True, alpha=0.3, linestyle='--', axis='y', color=colors['grid'])
    
    # Legend
    legend_elements = [
        Patch(facecolor=colors['intel_primary'], alpha=0.9, label='Intel Xeon Platinum 8358'),
        Patch(facecolor=colors['apple_primary'], alpha=0.9, label='Apple M4 (SME)'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', frameon=True, fontsize=14,
             framealpha=0.95, fancybox=False, edgecolor=colors['grid'])

def create_speedup_plot(ax, intel_data, apple_data, colors):
    """Create the speedup factor line chart"""
    optimization_levels = np.arange(5)
    
    # Intel speedup line
    ax.plot(optimization_levels, intel_data['speedup'], 
           'o-', color=colors['intel_primary'], 
           linewidth=3.0, markersize=11, markeredgewidth=2.5,
           markeredgecolor='white', label='Intel Xeon Platinum 8358', 
           alpha=0.9, zorder=3)
    
    # Intel数据标签 - 智能放置以避免重叠
    intel_label_positions = [
        (0, 0.7, 'bottom'),       # Baseline - 上方（增加间距）
        (1, 0.7, 'bottom'),       # im2row - 上方（增加间距）
        (2, 0.8, 'bottom'),   # Stencil2Row - 下方
        (3, 1.3, 'top'),       # SIMD - 上方
        (4, 1.3, 'top'),       # OpenMP - 上方
    ]
    
    for i, (x, y) in enumerate(zip(optimization_levels, intel_data['speedup'])):
        _, y_mult, va = intel_label_positions[i]
        if va == 'top':
            y_pos = y * y_mult
            va_text = 'bottom'
        else:
            y_pos = y * y_mult
            va_text = 'top'
        
        ax.text(x, y_pos, f'{y:.1f}×', 
               ha='center', va=va_text,
               fontsize=14, color=colors['intel_primary'], 
               fontweight='bold',
               bbox=dict(boxstyle='round,pad=0.2', facecolor='white', 
                        alpha=0.8, edgecolor=colors['intel_primary'], linewidth=0.5))
    
    # Apple speedup line
    ax.plot(optimization_levels, apple_data['speedup'],
           's-', color=colors['apple_primary'],
           linewidth=3.0, markersize=11, markeredgewidth=2.5,
           markeredgecolor='white', label='Apple M4 (SME)', 
           alpha=0.9, zorder=3)
    
    # Apple数据标签 - 智能放置以避免重叠
    apple_label_positions = [
        (0, 1.3, 'top'),    # Baseline - 下方（增加间距）
        (1, 1.3, 'top'),    # Im2Row - 下方（增加间距）
        (2, 1.3, 'top'),       # Stencil2Row - 上方
        (3, 1.3, 'top'),    # SME Single - 下方
        (4, 1.3, 'top'),    # SME 4-Tiles - 下方
    ]
    
    for i, (x, y) in enumerate(zip(optimization_levels, apple_data['speedup'])):
        _, y_mult, va = apple_label_positions[i]
        if va == 'top':
            y_pos = y * y_mult
            va_text = 'bottom'
        else:
            y_pos = y * y_mult
            va_text = 'top'
            
        ax.text(x, y_pos, f'{y:.1f}×', 
               ha='center', va=va_text,
               fontsize=14, color=colors['apple_primary'], 
               fontweight='bold',
               bbox=dict(boxstyle='round,pad=0.2', facecolor='white', 
                        alpha=0.8, edgecolor=colors['apple_primary'], linewidth=0.5))
    
    # Baseline reference line
    ax.axhline(y=1.0, color=colors['baseline'], 
              linestyle='--', linewidth=2.0, alpha=0.5, label='Baseline (1.0×)', zorder=1)
    
    # Configure axes
    ax.set_ylabel('Speedup Factor (×)', fontweight='bold', color=colors['text'])
    ax.set_yscale('log')
    ax.set_ylim([0.3, 200])  # 稍微增加上限以容纳标签
    ax.set_xlim([-0.3, 4.3])
    ax.set_xticks(optimization_levels)
    ax.set_xticklabels(intel_data['methods'], fontsize=14)
    ax.set_title('Speedup Factor Analysis', fontweight='bold', pad=15, color=colors['text'])
    ax.legend(loc='upper left', frameon=True, framealpha=0.95, fontsize=14,
             fancybox=False, edgecolor=colors['grid'])
    ax.grid(True, alpha=0.3, linestyle='--', zorder=0, color=colors['grid'])

def main():
    """Main function to create and save the visualization"""
    print("Starting visualization generation...")
    print("-" * 50)
    
    # Setup
    colors = setup_plot_style()
    intel_data, apple_data = load_data()
    
    # Create figure - 增加图形大小以适应更大的字体
    fig = plt.figure(figsize=(16, 7))
    
    # Create subplots
    ax1 = fig.add_subplot(1, 2, 1)
    ax2 = fig.add_subplot(1, 2, 2)
    
    # Generate plots
    create_execution_time_plot(ax1, intel_data, apple_data, colors)
    create_speedup_plot(ax2, intel_data, apple_data, colors)
    
    # Overall title and footer
    fig.suptitle('15×15 Stencil Computation Performance Analysis', 
                fontsize=19, fontweight='bold', y=1.02, color=colors['text'])
    
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
        filename = f'stencil_15x15_performance_comparison.{fmt}'
        plt.savefig(filename, dpi=settings['dpi'], 
                   bbox_inches='tight', facecolor='white')
        print(f'✓ Saved {filename} - {settings["desc"]}')
    
    # High-resolution version
    plt.savefig('stencil_15x15_performance_hires.png', dpi=600, 
               bbox_inches='tight', facecolor='white')
    print('✓ Saved stencil_15x15_performance_hires.png - Publication quality (600 DPI)')
    
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