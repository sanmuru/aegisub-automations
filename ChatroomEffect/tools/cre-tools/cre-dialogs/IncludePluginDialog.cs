using System;
using System.Data;
using System.IO;
using System.Linq;
using System.Windows.Forms;

namespace SamLu.Cre.Dialogs
{
    public partial class IncludePluginDialog : Form
    {
        public IncludePluginDialog()
        {
            InitializeComponent();
        }

        private void addSource(string path)
        {
            this.lvPlugins.Items.Add(new ListViewItem(new[] { "*", path }) { Checked = true });
        }

        private void removeSource(string path)
        {
            var items = this.lvPlugins.Items.OfType<ListViewItem>().Where(item => item.SubItems[2].Text == path).ToList();
            items.ForEach(item => this.lvPlugins.Items.Remove(item));
        }

        private void btnAddFile_Click(object sender, EventArgs e)
        {
            if (this.openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                foreach (var path in this.openFileDialog1.FileNames)
                {
                    if (this.lbSource.Items.OfType<string>().All(item => !string.Equals(item, path, StringComparison.OrdinalIgnoreCase)))
                    {
                        this.lbSource.Items.Add(path);
                        this.addSource(path);
                    }
                }
            }
        }

        private void btnAddFolder_Click(object sender, EventArgs e)
        {
            if (this.folderBrowserDialog1.ShowDialog() == DialogResult.OK)
            {
                foreach (string path in Directory.GetFiles(this.folderBrowserDialog1.SelectedPath).Where(f =>
                {
                    string extension = Path.GetExtension(f);
                    return string.Equals(extension, ".lua", StringComparison.OrdinalIgnoreCase) || string.Equals(extension, ".xml", StringComparison.OrdinalIgnoreCase);
                }
                ))
                {
                    if (this.lbSource.Items.OfType<string>().All(item => !string.Equals(item, path, StringComparison.OrdinalIgnoreCase)))
                    {
                        this.lbSource.Items.Add(path);
                        this.addSource(path);
                    }
                }
            }
        }

        private void btnRemove_Click(object sender, EventArgs e)
        {
            this.removeSource(this.lbSource.SelectedItem as string);
            this.lbSource.Items.Remove(this.lbSource.SelectedItem);
        }
    }
}
