using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Drawing.Design;

namespace SamLu.Cre.Dialogs.Controls
{
    public partial class ButtonList : UserControl
    {
        private string[] items = null;
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
        [Editor("System.Windows.Forms.Design.ListControlStringCollectionEditor, System.Design, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a", typeof(UITypeEditor))]
        public string[] Items { get => this.items; set
            {
                MessageBox.Show(value.Length.ToString());
            }
        }
        
        public ButtonList()
        {
            InitializeComponent();
        }
    }
}
