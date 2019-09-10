namespace SamLu.Cre.Dialogs.Controls
{
    partial class CategoryTitle
    {
        /// <summary> 
        /// 必需的设计器变量。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// 清理所有正在使用的资源。
        /// </summary>
        /// <param name="disposing">如果应释放托管资源，为 true；否则为 false。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region 组件设计器生成的代码

        /// <summary> 
        /// 设计器支持所需的方法 - 不要修改
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            this.tlpnlTitle = new System.Windows.Forms.TableLayoutPanel();
            this.lblSeparator = new System.Windows.Forms.Label();
            this.lblTItle = new System.Windows.Forms.Label();
            this.tlpnlTitle.SuspendLayout();
            this.SuspendLayout();
            // 
            // tlpnlTitle
            // 
            this.tlpnlTitle.ColumnCount = 2;
            this.tlpnlTitle.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
            this.tlpnlTitle.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tlpnlTitle.Controls.Add(this.lblSeparator, 0, 0);
            this.tlpnlTitle.Controls.Add(this.lblTItle, 0, 0);
            this.tlpnlTitle.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tlpnlTitle.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.tlpnlTitle.Location = new System.Drawing.Point(0, 0);
            this.tlpnlTitle.Name = "tlpnlTitle";
            this.tlpnlTitle.RowCount = 1;
            this.tlpnlTitle.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tlpnlTitle.Size = new System.Drawing.Size(232, 17);
            this.tlpnlTitle.TabIndex = 13;
            // 
            // lblSeparator
            // 
            this.lblSeparator.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right)));
            this.lblSeparator.AutoEllipsis = true;
            this.lblSeparator.BackColor = System.Drawing.SystemColors.ControlDark;
            this.lblSeparator.Location = new System.Drawing.Point(9, 8);
            this.lblSeparator.Name = "lblSeparator";
            this.lblSeparator.Size = new System.Drawing.Size(220, 1);
            this.lblSeparator.TabIndex = 9;
            // 
            // lblTItle
            // 
            this.lblTItle.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.lblTItle.AutoSize = true;
            this.lblTItle.Location = new System.Drawing.Point(3, 0);
            this.lblTItle.Name = "lblTItle";
            this.lblTItle.Size = new System.Drawing.Size(0, 17);
            this.lblTItle.TabIndex = 8;
            // 
            // CategoryTitle
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSize = true;
            this.Controls.Add(this.tlpnlTitle);
            this.Name = "CategoryTitle";
            this.Size = new System.Drawing.Size(232, 17);
            this.AutoSizeChanged += new System.EventHandler(this.CategoryTitle_AutoSizeChanged);
            this.tlpnlTitle.ResumeLayout(false);
            this.tlpnlTitle.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TableLayoutPanel tlpnlTitle;
        private System.Windows.Forms.Label lblSeparator;
        private System.Windows.Forms.Label lblTItle;
    }
}
