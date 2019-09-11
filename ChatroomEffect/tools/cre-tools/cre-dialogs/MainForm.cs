using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Xml;

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
                XmlDocument document = new XmlDocument();
                document.AppendChild(document.CreateXmlDeclaration("1.0", Encoding.UTF8.WebName, null));

                XmlElement settingsE = document.CreateElement("Settings");
                document.AppendChild(settingsE);

                XmlElement layoutsE = document.CreateElement("Layouts");
                settingsE.AppendChild(layoutsE);
                foreach (var item in this.ipvLayouts.PluginItems)
                {
                    XmlElement pluginE = document.CreateElement("Plugin");
                    layoutsE.AppendChild(pluginE);
                    pluginE.SetAttribute("Name", item.Name);
                    pluginE.SetAttribute("Source", item.Source);
                }

                XmlElement logicsE = document.CreateElement("Logics");
                settingsE.AppendChild(logicsE);
                foreach (var item in this.ipvLogics.PluginItems)
                {
                    XmlElement pluginE = document.CreateElement("Plugin");
                    logicsE.AppendChild(pluginE);
                    pluginE.SetAttribute("Name", item.Name);
                    pluginE.SetAttribute("Source", item.Source);
                }

                XmlElement speakersE = document.CreateElement("Speakers");
                settingsE.AppendChild(speakersE);
                foreach (var item in this.ipvSpeakers.PluginItems)
                {
                    XmlElement pluginE = document.CreateElement("Plugin");
                    speakersE.AppendChild(pluginE);
                    pluginE.SetAttribute("Name", item.Name);
                    pluginE.SetAttribute("Source", item.Source);
                }

                XmlElement shapesE = document.CreateElement("Shapes");
                settingsE.AppendChild(shapesE);
                foreach (var item in this.ipvShapes.PluginItems)
                {
                    XmlElement pluginE = document.CreateElement("Plugin");
                    shapesE.AppendChild(pluginE);
                    pluginE.SetAttribute("Name", item.Name);
                    pluginE.SetAttribute("Source", item.Source);
                }

                XmlElement animationsE = document.CreateElement("Animations");
                settingsE.AppendChild(animationsE);
                foreach (var item in this.ipvAnimations.PluginItems)
                {
                    XmlElement pluginE = document.CreateElement("Plugin");
                    animationsE.AppendChild(pluginE);
                    pluginE.SetAttribute("Name", item.Name);
                    pluginE.SetAttribute("Source", item.Source);
                }

                XmlElement applyToE = document.CreateElement("ApplyTo");
                settingsE.AppendChild(applyToE);
                if (this.rbtn_ApplyToAllLines.Checked) applyToE.SetAttribute("Target", "AllLines");
                else if (this.rbtn_ApplyToSelectedLines.Checked) applyToE.SetAttribute("Target", "SelectedLines");
                else if (this.rbtn_ApplyToEffectList.Checked)
                {
                    applyToE.SetAttribute("Target", "EffectList");
                    foreach (string effect in this.clb_EffectList.CheckedItems)
                    {
                        XmlElement effectE = document.CreateElement("Effect");
                        effectE.InnerText = effect;
                        applyToE.AppendChild(effectE);
                    }
                }

                document.Save(this.sfdSaveSettings.FileName);
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
