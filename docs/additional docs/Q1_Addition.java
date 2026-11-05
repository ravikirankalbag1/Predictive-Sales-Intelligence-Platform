import java.awt.*;
import java.awt.event.*;

public class Q1_Addition extends Frame implements ActionListener {
    TextField t1,t2;
    Label result;
    Button b;

    Q1_Addition() {
        t1=new TextField(); t2=new TextField();
        b=new Button("Add"); result=new Label("Result");

        add(new Label("Number 1:")); add(t1);
        add(new Label("Number 2:")); add(t2);
        add(b); add(result);

        b.addActionListener(this);
        setLayout(new FlowLayout());
        setSize(300,200); setVisible(true);
    }

    public void actionPerformed(ActionEvent e) {
        int a=Integer.parseInt(t1.getText());
        int c=Integer.parseInt(t2.getText());
        result.setText("Result = "+(a+c));
    }

    public static void main(String[] args) {
        new Q1_Addition();
    }
}