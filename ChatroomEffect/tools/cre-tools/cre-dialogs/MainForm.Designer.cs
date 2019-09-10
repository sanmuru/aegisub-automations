namespace SamLu.Cre.Dialogs
{
    partial class MainForm
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

        #region Windows 窗体设计器生成的代码

        /// <summary>
        /// 设计器支持所需的方法 - 不要修改
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            this.clb_EffectList = new System.Windows.Forms.CheckedListBox();
            this.btnReverseSelection = new System.Windows.Forms.Button();
            this.btnAllUnselected = new System.Windows.Forms.Button();
            this.btnAllSelected = new System.Windows.Forms.Button();
            this.splitContainer = new System.Windows.Forms.SplitContainer();
            this.btnSaveSettings = new System.Windows.Forms.Button();
            this.btnLoadSettings = new System.Windows.Forms.Button();
            this.btnApply = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.pnl_ApplyTo = new System.Windows.Forms.Panel();
            this.pnl_EffectList = new System.Windows.Forms.Panel();
            this.rbtn_ApplyToAllLines = new System.Windows.Forms.RadioButton();
            this.rbtn_ApplyToSelectedLines = new System.Windows.Forms.RadioButton();
            this.rbtn_ApplyToEffectList = new System.Windows.Forms.RadioButton();
            this.ofdLoadSettings = new System.Windows.Forms.OpenFileDialog();
            this.sfdSaveSettings = new System.Windows.Forms.SaveFileDialog();
            this.btnMenu_ApplyTo = new System.Windows.Forms.Button();
            this.cateTitle_ApplyTo = new SamLu.Cre.Dialogs.Controls.CategoryTitle();
            this.btnMenu_EssentialSettings = new System.Windows.Forms.Button();
            this.cateTitle_EssentialSettings = new SamLu.Cre.Dialogs.Controls.CategoryTitle();
            this.includedPluginView5 = new SamLu.Cre.Dialogs.Controls.IncludedPluginView();
            this.includedPluginView2 = new SamLu.Cre.Dialogs.Controls.IncludedPluginView();
            this.includedPluginView3 = new SamLu.Cre.Dialogs.Controls.IncludedPluginView();
            this.includedPluginView1 = new SamLu.Cre.Dialogs.Controls.IncludedPluginView();
            this.includedPluginView4 = new SamLu.Cre.Dialogs.Controls.IncludedPluginView();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).BeginInit();
            this.splitContainer.Panel1.SuspendLayout();
            this.splitContainer.Panel2.SuspendLayout();
            this.splitContainer.SuspendLayout();
            this.pnl_ApplyTo.SuspendLayout();
            this.pnl_EffectList.SuspendLayout();
            this.SuspendLayout();
            // 
            // clb_EffectList
            // 
            this.clb_EffectList.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.clb_EffectList.CheckOnClick = true;
            this.clb_EffectList.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.clb_EffectList.FormattingEnabled = true;
            this.clb_EffectList.IntegralHeight = false;
            this.clb_EffectList.Location = new System.Drawing.Point(0, 0);
            this.clb_EffectList.Name = "clb_EffectList";
            this.clb_EffectList.Size = new System.Drawing.Size(596, 156);
            this.clb_EffectList.TabIndex = 3;
            // 
            // btnReverseSelection
            // 
            this.btnReverseSelection.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnReverseSelection.Location = new System.Drawing.Point(506, 162);
            this.btnReverseSelection.Name = "btnReverseSelection";
            this.btnReverseSelection.Size = new System.Drawing.Size(90, 27);
            this.btnReverseSelection.TabIndex = 6;
            this.btnReverseSelection.Text = "反选";
            this.btnReverseSelection.UseVisualStyleBackColor = true;
            this.btnReverseSelection.Click += new System.EventHandler(this.btnReverseSelection_Click);
            // 
            // btnAllUnselected
            // 
            this.btnAllUnselected.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnAllUnselected.Location = new System.Drawing.Point(410, 162);
            this.btnAllUnselected.Name = "btnAllUnselected";
            this.btnAllUnselected.Size = new System.Drawing.Size(90, 27);
            this.btnAllUnselected.TabIndex = 5;
            this.btnAllUnselected.Text = "全不选";
            this.btnAllUnselected.UseVisualStyleBackColor = true;
            this.btnAllUnselected.Click += new System.EventHandler(this.btnAllUnselected_Click);
            // 
            // btnAllSelected
            // 
            this.btnAllSelected.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnAllSelected.Location = new System.Drawing.Point(314, 162);
            this.btnAllSelected.Name = "btnAllSelected";
            this.btnAllSelected.Size = new System.Drawing.Size(90, 27);
            this.btnAllSelected.TabIndex = 4;
            this.btnAllSelected.Text = "全选";
            this.btnAllSelected.UseVisualStyleBackColor = true;
            this.btnAllSelected.Click += new System.EventHandler(this.btnAllSelected_Click);
            // 
            // splitContainer
            // 
            this.splitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer.FixedPanel = System.Windows.Forms.FixedPanel.Panel1;
            this.splitContainer.Location = new System.Drawing.Point(0, 0);
            this.splitContainer.Name = "splitContainer";
            // 
            // splitContainer.Panel1
            // 
            this.splitContainer.Panel1.Controls.Add(this.btnSaveSettings);
            this.splitContainer.Panel1.Controls.Add(this.btnLoadSettings);
            this.splitContainer.Panel1.Controls.Add(this.btnApply);
            this.splitContainer.Panel1.Controls.Add(this.btnCancel);
            this.splitContainer.Panel1.Controls.Add(this.btnMenu_ApplyTo);
            this.splitContainer.Panel1.Controls.Add(this.btnMenu_EssentialSettings);
            this.splitContainer.Panel1MinSize = 100;
            // 
            // splitContainer.Panel2
            // 
            this.splitContainer.Panel2.AutoScroll = true;
            this.splitContainer.Panel2.AutoScrollMargin = new System.Drawing.Size(0, 8);
            this.splitContainer.Panel2.BackColor = System.Drawing.SystemColors.ControlLightLight;
            this.splitContainer.Panel2.Controls.Add(this.cateTitle_EssentialSettings);
            this.splitContainer.Panel2.Controls.Add(this.includedPluginView5);
            this.splitContainer.Panel2.Controls.Add(this.cateTitle_ApplyTo);
            this.splitContainer.Panel2.Controls.Add(this.includedPluginView2);
            this.splitContainer.Panel2.Controls.Add(this.includedPluginView3);
            this.splitContainer.Panel2.Controls.Add(this.includedPluginView1);
            this.splitContainer.Panel2.Controls.Add(this.pnl_ApplyTo);
            this.splitContainer.Panel2.Controls.Add(this.includedPluginView4);
            this.splitContainer.Panel2.Scroll += new System.Windows.Forms.ScrollEventHandler(this.SplitContainer_Panel2_Scroll);
            this.splitContainer.Size = new System.Drawing.Size(784, 561);
            this.splitContainer.SplitterDistance = 120;
            this.splitContainer.TabIndex = 7;
            // 
            // btnSaveSettings
            // 
            this.btnSaveSettings.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.btnSaveSettings.FlatAppearance.BorderSize = 0;
            this.btnSaveSettings.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSaveSettings.Location = new System.Drawing.Point(0, 441);
            this.btnSaveSettings.Name = "btnSaveSettings";
            this.btnSaveSettings.Size = new System.Drawing.Size(120, 30);
            this.btnSaveSettings.TabIndex = 6;
            this.btnSaveSettings.Text = "保存设置(&S)";
            this.btnSaveSettings.UseVisualStyleBackColor = true;
            this.btnSaveSettings.Click += new System.EventHandler(this.btnSaveSettings_Click);
            // 
            // btnLoadSettings
            // 
            this.btnLoadSettings.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.btnLoadSettings.FlatAppearance.BorderSize = 0;
            this.btnLoadSettings.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnLoadSettings.Location = new System.Drawing.Point(0, 471);
            this.btnLoadSettings.Name = "btnLoadSettings";
            this.btnLoadSettings.Size = new System.Drawing.Size(120, 30);
            this.btnLoadSettings.TabIndex = 5;
            this.btnLoadSettings.Text = "加载设置(&L)";
            this.btnLoadSettings.UseVisualStyleBackColor = true;
            this.btnLoadSettings.Click += new System.EventHandler(this.btnLoadSettings_Click);
            // 
            // btnApply
            // 
            this.btnApply.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.btnApply.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.btnApply.FlatAppearance.BorderSize = 0;
            this.btnApply.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnApply.Location = new System.Drawing.Point(0, 501);
            this.btnApply.Name = "btnApply";
            this.btnApply.Size = new System.Drawing.Size(120, 30);
            this.btnApply.TabIndex = 4;
            this.btnApply.Text = "应用(&A)";
            this.btnApply.UseVisualStyleBackColor = true;
            // 
            // btnCancel
            // 
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.btnCancel.FlatAppearance.BorderSize = 0;
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.Location = new System.Drawing.Point(0, 531);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(120, 30);
            this.btnCancel.TabIndex = 3;
            this.btnCancel.Text = "取消(&C)";
            this.btnCancel.UseVisualStyleBackColor = true;
            // 
            // pnl_ApplyTo
            // 
            this.pnl_ApplyTo.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.pnl_ApplyTo.Controls.Add(this.pnl_EffectList);
            this.pnl_ApplyTo.Controls.Add(this.rbtn_ApplyToAllLines);
            this.pnl_ApplyTo.Controls.Add(this.rbtn_ApplyToSelectedLines);
            this.pnl_ApplyTo.Controls.Add(this.rbtn_ApplyToEffectList);
            this.pnl_ApplyTo.Location = new System.Drawing.Point(41, 1202);
            this.pnl_ApplyTo.Name = "pnl_ApplyTo";
            this.pnl_ApplyTo.Size = new System.Drawing.Size(599, 273);
            this.pnl_ApplyTo.TabIndex = 4;
            // 
            // pnl_EffectList
            // 
            this.pnl_EffectList.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.pnl_EffectList.Controls.Add(this.clb_EffectList);
            this.pnl_EffectList.Controls.Add(this.btnReverseSelection);
            this.pnl_EffectList.Controls.Add(this.btnAllUnselected);
            this.pnl_EffectList.Controls.Add(this.btnAllSelected);
            this.pnl_EffectList.Enabled = false;
            this.pnl_EffectList.Location = new System.Drawing.Point(3, 84);
            this.pnl_EffectList.Name = "pnl_EffectList";
            this.pnl_EffectList.Size = new System.Drawing.Size(596, 189);
            this.pnl_EffectList.TabIndex = 7;
            // 
            // rbtn_ApplyToAllLines
            // 
            this.rbtn_ApplyToAllLines.AutoSize = true;
            this.rbtn_ApplyToAllLines.Checked = true;
            this.rbtn_ApplyToAllLines.Location = new System.Drawing.Point(3, 3);
            this.rbtn_ApplyToAllLines.Name = "rbtn_ApplyToAllLines";
            this.rbtn_ApplyToAllLines.Size = new System.Drawing.Size(98, 21);
            this.rbtn_ApplyToAllLines.TabIndex = 0;
            this.rbtn_ApplyToAllLines.TabStop = true;
            this.rbtn_ApplyToAllLines.Text = "应用到所有行";
            this.rbtn_ApplyToAllLines.UseVisualStyleBackColor = true;
            this.rbtn_ApplyToAllLines.CheckedChanged += new System.EventHandler(this.rbtn_ApplyTo_CheckedChanged);
            // 
            // rbtn_ApplyToSelectedLines
            // 
            this.rbtn_ApplyToSelectedLines.AutoSize = true;
            this.rbtn_ApplyToSelectedLines.Location = new System.Drawing.Point(3, 30);
            this.rbtn_ApplyToSelectedLines.Name = "rbtn_ApplyToSelectedLines";
            this.rbtn_ApplyToSelectedLines.Size = new System.Drawing.Size(98, 21);
            this.rbtn_ApplyToSelectedLines.TabIndex = 1;
            this.rbtn_ApplyToSelectedLines.Text = "应用到选中行";
            this.rbtn_ApplyToSelectedLines.UseVisualStyleBackColor = true;
            this.rbtn_ApplyToSelectedLines.CheckedChanged += new System.EventHandler(this.rbtn_ApplyTo_CheckedChanged);
            // 
            // rbtn_ApplyToEffectList
            // 
            this.rbtn_ApplyToEffectList.AutoSize = true;
            this.rbtn_ApplyToEffectList.Location = new System.Drawing.Point(3, 57);
            this.rbtn_ApplyToEffectList.Name = "rbtn_ApplyToEffectList";
            this.rbtn_ApplyToEffectList.Size = new System.Drawing.Size(122, 21);
            this.rbtn_ApplyToEffectList.TabIndex = 2;
            this.rbtn_ApplyToEffectList.Text = "在以下特效中选择";
            this.rbtn_ApplyToEffectList.UseVisualStyleBackColor = true;
            this.rbtn_ApplyToEffectList.CheckedChanged += new System.EventHandler(this.rbtn_ApplyTo_CheckedChanged);
            // 
            // ofdLoadSettings
            // 
            this.ofdLoadSettings.Filter = "配置文件(*.config)|*.config|所有文件(*.*)|*.*";
            this.ofdLoadSettings.Title = "加载设置";
            // 
            // sfdSaveSettings
            // 
            this.sfdSaveSettings.DefaultExt = "config";
            this.sfdSaveSettings.FileName = "settings";
            this.sfdSaveSettings.Filter = "配置文件(*.config)|*.config|所有文件(*.*)|*.*";
            this.sfdSaveSettings.Title = "保存设置";
            // 
            // btnMenu_ApplyTo
            // 
            this.btnMenu_ApplyTo.Dock = System.Windows.Forms.DockStyle.Top;
            this.btnMenu_ApplyTo.FlatAppearance.BorderSize = 0;
            this.btnMenu_ApplyTo.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnMenu_ApplyTo.Location = new System.Drawing.Point(0, 30);
            this.btnMenu_ApplyTo.Name = "btnMenu_ApplyTo";
            this.btnMenu_ApplyTo.Size = new System.Drawing.Size(120, 30);
            this.btnMenu_ApplyTo.TabIndex = 2;
            this.btnMenu_ApplyTo.Tag = this.cateTitle_ApplyTo;
            this.btnMenu_ApplyTo.Text = "应用到";
            this.btnMenu_ApplyTo.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnMenu_ApplyTo.UseVisualStyleBackColor = true;
            this.btnMenu_ApplyTo.Click += new System.EventHandler(this.btnMenu_Click);
            // 
            // cateTitle_ApplyTo
            // 
            this.cateTitle_ApplyTo.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.cateTitle_ApplyTo.AutoSize = true;
            this.cateTitle_ApplyTo.Location = new System.Drawing.Point(1, 1179);
            this.cateTitle_ApplyTo.Name = "cateTitle_ApplyTo";
            this.cateTitle_ApplyTo.Size = new System.Drawing.Size(636, 17);
            this.cateTitle_ApplyTo.TabIndex = 5;
            this.cateTitle_ApplyTo.TitleText = "应用到";
            // 
            // btnMenu_EssentialSettings
            // 
            this.btnMenu_EssentialSettings.BackColor = System.Drawing.SystemColors.ControlDarkDark;
            this.btnMenu_EssentialSettings.Dock = System.Windows.Forms.DockStyle.Top;
            this.btnMenu_EssentialSettings.FlatAppearance.BorderSize = 0;
            this.btnMenu_EssentialSettings.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnMenu_EssentialSettings.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnMenu_EssentialSettings.ForeColor = System.Drawing.SystemColors.HighlightText;
            this.btnMenu_EssentialSettings.Location = new System.Drawing.Point(0, 0);
            this.btnMenu_EssentialSettings.Name = "btnMenu_EssentialSettings";
            this.btnMenu_EssentialSettings.Size = new System.Drawing.Size(120, 30);
            this.btnMenu_EssentialSettings.TabIndex = 0;
            this.btnMenu_EssentialSettings.Tag = this.cateTitle_EssentialSettings;
            this.btnMenu_EssentialSettings.Text = "基本设置";
            this.btnMenu_EssentialSettings.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnMenu_EssentialSettings.UseVisualStyleBackColor = false;
            this.btnMenu_EssentialSettings.Click += new System.EventHandler(this.btnMenu_Click);
            // 
            // cateTitle_EssentialSettings
            // 
            this.cateTitle_EssentialSettings.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.cateTitle_EssentialSettings.AutoSize = true;
            this.cateTitle_EssentialSettings.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.cateTitle_EssentialSettings.Location = new System.Drawing.Point(2, 8);
            this.cateTitle_EssentialSettings.Margin = new System.Windows.Forms.Padding(3, 8, 3, 8);
            this.cateTitle_EssentialSettings.Name = "cateTitle_EssentialSettings";
            this.cateTitle_EssentialSettings.Size = new System.Drawing.Size(635, 17);
            this.cateTitle_EssentialSettings.TabIndex = 7;
            this.cateTitle_EssentialSettings.TitleText = "基本设置";
            // 
            // includedPluginView5
            // 
            this.includedPluginView5.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.includedPluginView5.BrowseText = "动画(&A)";
            this.includedPluginView5.DescriptionText = "动画。";
            this.includedPluginView5.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.includedPluginView5.Location = new System.Drawing.Point(2, 950);
            this.includedPluginView5.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.includedPluginView5.Name = "includedPluginView5";
            this.includedPluginView5.Size = new System.Drawing.Size(635, 222);
            this.includedPluginView5.TabIndex = 10;
            this.includedPluginView5.TitleText = "动画";
            // 
            // includedPluginView2
            // 
            this.includedPluginView2.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.includedPluginView2.BrowseText = "布局逻辑(&P)";
            this.includedPluginView2.DescriptionText = "布局逻辑。";
            this.includedPluginView2.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.includedPluginView2.Location = new System.Drawing.Point(2, 260);
            this.includedPluginView2.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.includedPluginView2.Name = "includedPluginView2";
            this.includedPluginView2.Size = new System.Drawing.Size(635, 222);
            this.includedPluginView2.TabIndex = 6;
            this.includedPluginView2.TitleText = "布局逻辑";
            // 
            // includedPluginView3
            // 
            this.includedPluginView3.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.includedPluginView3.BrowseText = "形状(&S)";
            this.includedPluginView3.DescriptionText = "形状。";
            this.includedPluginView3.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.includedPluginView3.Location = new System.Drawing.Point(2, 720);
            this.includedPluginView3.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.includedPluginView3.Name = "includedPluginView3";
            this.includedPluginView3.Size = new System.Drawing.Size(635, 222);
            this.includedPluginView3.TabIndex = 8;
            this.includedPluginView3.TitleText = "形状";
            // 
            // includedPluginView1
            // 
            this.includedPluginView1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.includedPluginView1.BrowseText = "布局(&L)";
            this.includedPluginView1.DescriptionText = "布局是用来表示复杂的绘图层次中各素材布置的方式。";
            this.includedPluginView1.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.includedPluginView1.Location = new System.Drawing.Point(2, 30);
            this.includedPluginView1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.includedPluginView1.Name = "includedPluginView1";
            this.includedPluginView1.Size = new System.Drawing.Size(635, 222);
            this.includedPluginView1.TabIndex = 6;
            this.includedPluginView1.TitleText = "布局";
            // 
            // includedPluginView4
            // 
            this.includedPluginView4.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.includedPluginView4.BrowseText = "说话人(&A)";
            this.includedPluginView4.DescriptionText = "说话人。";
            this.includedPluginView4.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.includedPluginView4.Location = new System.Drawing.Point(2, 490);
            this.includedPluginView4.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.includedPluginView4.Name = "includedPluginView4";
            this.includedPluginView4.Size = new System.Drawing.Size(635, 222);
            this.includedPluginView4.TabIndex = 9;
            this.includedPluginView4.TitleText = "说话人";
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 17F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(784, 561);
            this.Controls.Add(this.splitContainer);
            this.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.MinimumSize = new System.Drawing.Size(480, 480);
            this.Name = "MainForm";
            this.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Show;
            this.Text = "Form1";
            this.splitContainer.Panel1.ResumeLayout(false);
            this.splitContainer.Panel2.ResumeLayout(false);
            this.splitContainer.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).EndInit();
            this.splitContainer.ResumeLayout(false);
            this.pnl_ApplyTo.ResumeLayout(false);
            this.pnl_ApplyTo.PerformLayout();
            this.pnl_EffectList.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.CheckedListBox clb_EffectList;
        private System.Windows.Forms.Button btnReverseSelection;
        private System.Windows.Forms.Button btnAllUnselected;
        private System.Windows.Forms.Button btnAllSelected;
        private System.Windows.Forms.SplitContainer splitContainer;
        private System.Windows.Forms.RadioButton rbtn_ApplyToAllLines;
        private System.Windows.Forms.RadioButton rbtn_ApplyToEffectList;
        private System.Windows.Forms.RadioButton rbtn_ApplyToSelectedLines;
        private System.Windows.Forms.Button btnMenu_EssentialSettings;
        private System.Windows.Forms.Button btnMenu_ApplyTo;
        private Controls.CategoryTitle cateTitle_ApplyTo;
        private System.Windows.Forms.Panel pnl_ApplyTo;
        private Controls.IncludedPluginView includedPluginView1;
        private Controls.CategoryTitle cateTitle_EssentialSettings;
        private System.Windows.Forms.Button btnSaveSettings;
        private System.Windows.Forms.Button btnLoadSettings;
        private System.Windows.Forms.Button btnApply;
        private System.Windows.Forms.Button btnCancel;
        private Controls.IncludedPluginView includedPluginView2;
        private Controls.IncludedPluginView includedPluginView3;
        private Controls.IncludedPluginView includedPluginView4;
        private Controls.IncludedPluginView includedPluginView5;
        private System.Windows.Forms.OpenFileDialog ofdLoadSettings;
        private System.Windows.Forms.SaveFileDialog sfdSaveSettings;
        private System.Windows.Forms.Panel pnl_EffectList;
    }
}

