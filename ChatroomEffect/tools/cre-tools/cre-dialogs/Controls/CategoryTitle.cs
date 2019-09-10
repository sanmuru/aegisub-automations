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
    public partial class CategoryTitle : UserControl
    {
        [DefaultValue(false)]
        public override bool AutoSize { get => base.AutoSize; set => base.AutoSize = value; }

        [Category("内部组件")]
        [Description("内部标题的文本。")]
        public string TitleText { get => this.lblTItle.Text; set => this.lblTItle.Text = value; }

        public new int Height { get => base.Height; set
            {
                if (!this.AutoSize) base.Height = value;
            }
        }

        public new Size Size { get => base.Size; set
            {
                if (!this.AutoSize)
                    base.Size = value;
                else if (base.Size.Width != value.Width)
                    base.Size = new Size(value.Width, this.Size.Height);
            }
        }

        public CategoryTitle()
        {
            InitializeComponent();
        }

        protected override void OnSizeChanged(EventArgs e)
        {
            if (this.AutoSize)
                base.Size = new Size(this.Size.Width, this.lblTItle.Height);
            else
            {
                base.OnSizeChanged(e);
                this.Invalidate();
            }
        }

        private void CategoryTitle_AutoSizeChanged(object sender, EventArgs e)
        {
            if (this.AutoSize) base.Height = this.lblTItle.Height;
        }
    }
}
