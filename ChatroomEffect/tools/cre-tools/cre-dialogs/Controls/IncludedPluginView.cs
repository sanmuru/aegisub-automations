using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace SamLu.Cre.Dialogs.Controls
{
    public partial class IncludedPluginView : UserControl
    {
        [Category("内部组件")]
        [Description("内部标题的文本。")]
        public string TitleText { get => this.cateTitle.TitleText; set => this.cateTitle.TitleText = value; }
        
        [Category("内部组件")]
        [Description("内部标题的描述。")]
        public string DescriptionText { get => this.lblDescription.Text; set => this.lblDescription.Text = value; }

        [Category("内部组件")]
        [Description("浏览按钮的文本。")]
        public string BrowseText { get => this.btnEdit.Text; set => this.btnEdit.Text = value; }

        private IncludePluginDialog defaultDialog = new IncludePluginDialog();
        private IncludePluginDialog dialog = null;
        [Category("内部组件")]
        [Description("支持浏览行为的对话框。")]
        public IncludePluginDialog IncludePluginDialog { get => this.dialog ?? this.defaultDialog; set => this.dialog = value; }

        public IncludedPluginView()
        {
            InitializeComponent();
        }

        private void BtnEdit_Click(object sender, EventArgs e)
        {
            if (this.IncludePluginDialog.ShowDialog() == DialogResult.OK)
            {
                this.lvPlugins.Items.Clear();

                foreach (ListViewItem item in this.IncludePluginDialog.lvPlugins.CheckedItems)
                {
                    var newItem = new ListViewItem(
                        item.SubItems.OfType<ListViewItem.ListViewSubItem>().Select(subItem => subItem.Text).ToArray()
                    );
                    this.lvPlugins.Items.Add(newItem);
                }
            }
        }
    }
}
