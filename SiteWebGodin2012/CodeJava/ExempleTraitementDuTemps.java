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

    // Connexion � une BD
    Connection uneConnection =
      DriverManager.getConnection ("jdbc:oracle:thin:@localhost:1521:ora9i", "godin", "oracle");

/*      PreparedStatement unEnonc�SQL = uneConnection.prepareStatement
        ("DROP TABLE LeTemps");
      int n = unEnonc�SQL.executeUpdate();  
*/
       PreparedStatement unEnonc�SQL = uneConnection.prepareStatement
      ("CREATE TABLE LeTemps(id NUMBER, laDate DATE, lHeure DATE, laDateEtHeure DATE)");
       int n = unEnonc�SQL.executeUpdate();  

       unEnonc�SQL = uneConnection.prepareStatement
        ("INSERT INTO LeTemps(id,laDate,lHeure,laDateEtHeure) VALUES(?,?,?,?)");
        unEnonc�SQL.setInt(1,1);
        Calendar maintenant = Calendar.getInstance(); // cr�e un calendrier gr�gorien avec date actuelle


        // Traitement de la date (sans l'heure)
        // Calendar.getTime() retourne un java.util.Date
        // java.util.Date.getTime() retourne le temps en long
        java.sql.Date laDate = new java.sql.Date(maintenant.getTime().getTime());
        unEnonc�SQL.setDate(2,laDate);

        // Traitement de l'heure (sans la date)
        java.sql.Time leTime = new java.sql.Time(maintenant.getTime().getTime());
        unEnonc�SQL.setTime(3,leTime);

        // Date + heure
        java.sql.Timestamp leTimestamp = new java.sql.Timestamp(maintenant.getTime().getTime());
        unEnonc�SQL.setTimestamp(4,leTimestamp);

        n = unEnonc�SQL.executeUpdate();

    unEnonc�SQL = uneConnection.prepareStatement
        ("SELECT id,laDate,lHeure,laDateEtHeure FROM LeTemps" );
    ResultSet r�sultatSelect = unEnonc�SQL.executeQuery();
    while (r�sultatSelect.next ()){
        int leId = r�sultatSelect.getInt("id");
        laDate = r�sultatSelect.getDate("laDate");
        leTime = r�sultatSelect.getTime("lHeure");
        leTimestamp = r�sultatSelect.getTimestamp("laDateEtHeure");
        
        System.out.println ("id:" + leId);
        System.out.println ("la date :" + laDate);
        System.out.println ("l'heure :" + leTime);
        System.out.println ("la date avec l'heure :" + leTimestamp);
    }
    // Fermeture de l'�nonc� et de la connexion
    unEnonc�SQL.close();
    uneConnection.close();
  }
}