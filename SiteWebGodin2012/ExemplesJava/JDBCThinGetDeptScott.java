// Exemple de programme JAVA qui utilise le pilote JDBC thin d'Oracle
// pour effectuer un SELECT et itérer sur les lignes du résultat

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

    // Connection à une BD à distanceavec un pilote thin
    Connection uneConnection =
      DriverManager.getConnection ("jdbc:oracle:thin:@labunix.uqam.ca:1521:o8db", "scott", "tiger");
    // NB L'adresse 127.0.0.1 peut être utilisée afin d'accéder à une BD locale !
    
    // Création d'un énoncé associé à la Connection
    Statement unEnoncéSQL = uneConnection.createStatement ();

    // Exécution d'un SELECT
    ResultSet résultatSelect = unEnoncéSQL.executeQuery
      ("SELECT deptno, dname "+
      "FROM DEPT " +
      "WHERE deptno > 10");

    // Itérer sur les lignes du résultat du SELECT et extraire les valeurs
    // des colonnes dans des variables JAVA
    
    while (résultatSelect.next ()){
      int deptno = résultatSelect.getInt ("deptno");
      String dname = résultatSelect.getString ("dname");

      System.out.println ("Numéro du departement:" + deptno);
      System.out.println ("Nom du departement:" + dname);
    }
    // Fermeture de l'énoncé et de la connexion
    unEnoncéSQL.close();
    uneConnection.close();
  }
}
