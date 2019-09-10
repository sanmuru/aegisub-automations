using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace SamLu.Cre.Dialogs
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
        }

        private void rbtn_ApplyTo_CheckedChanged(object sender, EventArgs e)
        {
            this.pnl_EffectList.Enabled = sender == this.rbtn_ApplyToEffectList;
        }

        private void btnAllSelected_Click(object sender, EventArgs e)
        {
            for (int index = 0; index < this.clb_EffectList.Items.Count; index++)
                this.clb_EffectList.SetItemChecked(index, true);
        }

        private void btnAllUnselected_Click(object sender, EventArgs e)
        {
            for (int index = 0; index < this.clb_EffectList.Items.Count; index++)
                this.clb_EffectList.SetItemChecked(index, false);
        }

        private void btnReverseSelection_Click(object sender, EventArgs e)
        {
            for (int index = 0; index < this.clb_EffectList.Items.Count; index++)
                this.clb_EffectList.SetItemChecked(index, !this.clb_EffectList.GetItemChecked(index));
        }

        private void btnMenu_Click(object sender, EventArgs e)
        {
            Button curMenuButton = sender as Button;
            var verticalScroll = this.splitContainer.Panel2.VerticalScroll;
            verticalScroll.Value = Math.Min(
                verticalScroll.Maximum - this.splitContainer.Panel2.Height,
                Math.Max(0, (curMenuButton.Tag as Control).Location.Y + verticalScroll.Value - 8)
            );
            (curMenuButton.Tag as Control).Focus();

            foreach (Control ctrl in this.splitContainer.Panel1.Controls)
            {
                if (ctrl is Button btn && btn.Name.StartsWith("btnMenu_"))
                {
                    if (btn == curMenuButton)
                    {
                        btn.BackColor = SystemColors.ControlDarkDark;
                        btn.ForeColor = SystemColors.HighlightText;
                        btn.Font = new Font(btn.Font, FontStyle.Bold);
                    }
                    else
                    {
                        btn.BackColor = SystemColors.Control;
                        btn.ForeColor = SystemColors.WindowText;
                        btn.Font = new Font(btn.Font, FontStyle.Regular);
                    }
                }
            }
        }

        private void SplitContainer_Panel2_Scroll(object sender, ScrollEventArgs e)
        {
            Button curMenuButton = sender as Button;
            foreach (Control ctrl in this.splitContainer.Panel1.Controls)
            {
                if (ctrl is Button btn && btn.Name.StartsWith("btnMenu_"))
                {
                    if (btn == curMenuButton)
                    {
                        btn.BackColor = SystemColors.ControlDarkDark;
                        btn.ForeColor = SystemColors.HighlightText;
                        btn.Font = new Font(btn.Font, FontStyle.Bold);
                    }
                    else
                    {
                        btn.BackColor = SystemColors.Control;
                        btn.ForeColor = SystemColors.WindowText;
                        btn.Font = new Font(btn.Font, FontStyle.Regular);
                    }
                }
            }
        }

        private void btnSaveSettings_Click(object sender, EventArgs e)
        {
            if (this.sfdSaveSettings.ShowDialog() == DialogResult.OK)
            {

            }
        }

        private void btnLoadSettings_Click(object sender, EventArgs e)
        {
            if (this.ofdLoadSettings.ShowDialog() == DialogResult.OK)
            {

            }
        }
    }
}
