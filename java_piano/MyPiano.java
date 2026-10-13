import java.awt.GridLayout;
import javax.swing.JButton;
import javax.swing.JFrame;

public class MyPiano extends JFrame {

    private static final String[] NOTES = {"도", "레", "미", "파", "솔", "라", "시", "도"};

    public MyPiano() {
        super("My Piano");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        // 1행 8열의 GridLayout으로 건반을 가로로 나란히 배치
        setLayout(new GridLayout(1, NOTES.length));

        for (String note : NOTES) {
            add(new JButton(note));
        }

        setSize(1000, 300);
        setVisible(true);
    }

    public static void main(String[] args) {
        new MyPiano();
    }
}
