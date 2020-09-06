// Traitement du temps avec le type DATE Oracle

package ExemplesJDBC;
import java.sql.*;
import java.util.*;

public class ExempleTraitementDuTemps 
{
  public static void main (String args [])
       throws SQLException, ClassNotFoundException, java.io.IOException
  {
    // Charger le pilote JDBC d'Oracle
    Class.forName ("oracle.jdbc.driver.OracleDriver");

    // Connexion à une BD
    Connection uneConnection =
      DriverManager.getConnection ("jdbc:oracle:thin:@localhost:1521:ora9i", "godin", "oracle");

/*      PreparedStatement unEnoncéSQL = uneConnection.prepareStatement
        ("DROP TABLE LeTemps");
      int n = unEnoncéSQL.executeUpdate();  
*/
       PreparedStatement unEnoncéSQL = uneConnection.prepareStatement
      ("CREATE TABLE LeTemps(id NUMBER, laDate DATE, lHeure DATE, laDateEtHeure DATE)");
       int n = unEnoncéSQL.executeUpdate();  

       unEnoncéSQL = uneConnection.prepareStatement
        ("INSERT INTO LeTemps(id,laDate,lHeure,laDateEtHeure) VALUES(?,?,?,?)");
        unEnoncéSQL.setInt(1,1);
        Calendar maintenant = Calendar.getInstance(); // crée un calendrier grégorien avec date actuelle


        // Traitement de la date (sans l'heure)
        // Calendar.getTime() retourne un java.util.Date
        // java.util.Date.getTime() retourne le temps en long
        java.sql.Date laDate = new java.sql.Date(maintenant.getTime().getTime());
        unEnoncéSQL.setDate(2,laDate);

        // Traitement de l'heure (sans la date)
        java.sql.Time leTime = new java.sql.Time(maintenant.getTime().getTime());
        unEnoncéSQL.setTime(3,leTime);

        // Date + heure
        java.sql.Timestamp leTimestamp = new java.sql.Timestamp(maintenant.getTime().getTime());
        unEnoncéSQL.setTimestamp(4,leTimestamp);

        n = unEnoncéSQL.executeUpdate();

    unEnoncéSQL = uneConnection.prepareStatement
        ("SELECT id,laDate,lHeure,laDateEtHeure FROM LeTemps" );
    ResultSet résultatSelect = unEnoncéSQL.executeQuery();
    while (résultatSelect.next ()){
        int leId = résultatSelect.getInt("id");
        laDate = résultatSelect.getDate("laDate");
        leTime = résultatSelect.getTime("lHeure");
        leTimestamp = résultatSelect.getTimestamp("laDateEtHeure");
        
        System.out.println ("id:" + leId);
        System.out.println ("la date :" + laDate);
        System.out.println ("l'heure :" + leTime);
        System.out.println ("la date avec l'heure :" + leTimestamp);
    }
    // Fermeture de l'énoncé et de la connexion
    unEnoncéSQL.close();
    uneConnection.close();
  }
}