// Exemple de programme JAVA qui utilise le pilote JDBC thin d'Oracle
// pour effectuer un SELECT et it�rer sur les lignes du r�sultat

// Il faut importer le paquetage java.sql pour utiliser JDBC
package ExemplesJDBC;
import java.sql.*;

class JDBCThinGetDeptScott
{
  public static void main (String args [])
       throws SQLException, ClassNotFoundException, java.io.IOException
  {
    // Charger le pilote JDBC d'Oracle
    Class.forName ("oracle.jdbc.driver.OracleDriver");

    // Connection � une BD � distanceavec un pilote thin
    Connection uneConnection =
      DriverManager.getConnection ("jdbc:oracle:thin:@labunix.uqam.ca:1521:o8db", "scott", "tiger");
    // NB L'adresse 127.0.0.1 peut �tre utilis�e afin d'acc�der � une BD locale !
    
    // Cr�ation d'un �nonc� associ� � la Connection
    Statement unEnonc�SQL = uneConnection.createStatement ();

    // Ex�cution d'un SELECT
    ResultSet r�sultatSelect = unEnonc�SQL.executeQuery
      ("SELECT deptno, dname "+
      "FROM DEPT " +
      "WHERE deptno > 10");

    // It�rer sur les lignes du r�sultat du SELECT et extraire les valeurs
    // des colonnes dans des variables JAVA
    
    while (r�sultatSelect.next ()){
      int deptno = r�sultatSelect.getInt ("deptno");
      String dname = r�sultatSelect.getString ("dname");

      System.out.println ("Num�ro du departement:" + deptno);
      System.out.println ("Nom du departement:" + dname);
    }
    // Fermeture de l'�nonc� et de la connexion
    unEnonc�SQL.close();
    uneConnection.close();
  }
}
