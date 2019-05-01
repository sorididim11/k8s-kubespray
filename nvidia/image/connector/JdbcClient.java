import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.io.Writer;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public class JdbcClient {
	public static long getUsedMemory() {
		return (Runtime.getRuntime().maxMemory() - Runtime.getRuntime().freeMemory()) / 1024768;
	}

	public static void main(String[] args) throws SQLException, IOException {
		// java -jar JdbcClient-1.0.0.jar <type:oracle/hive> <sql> <filename>
		String type = args[0];
		String sql = args[1];
		String filename = args[2];
		String separator = args[3];

		System.out.println("[JdbcClient] type : " + type);
		System.out.println("[JdbcClient] sql : " + sql);
		System.out.println("[JdbcClient] filename : " + filename);
		System.out.println("[JdbcClient] separator : " + separator);

		Properties prop = new Properties();
		InputStream input = null;
		String driverName = null;
		String url = null;
		String username = null;
		String password = null;
		String outDir = null;
		try {
			input = new FileInputStream("/etc/datalake/datalake.properties");
			prop.load(input);
			switch (type) {
			case "hive":
				driverName = prop.getProperty("hive.datasource.driver");
				url = prop.getProperty("hive.datasource.url");
				username = prop.getProperty("hive.datasource.username");
				password = prop.getProperty("hive.datasource.password");
				outDir = prop.getProperty("hive.datasource.outdir");
				break;
			case "oracle":
				driverName = prop.getProperty("oracle.datasource.driver");
				url = prop.getProperty("oracle.datasource.url");
				username = prop.getProperty("oracle.datasource.username");
				password = prop.getProperty("oracle.datasource.password");
				outDir = prop.getProperty("oracle.datasource.outdir");
				break;

			default:
				break;
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			input.close();
		}

		outDir = (outDir != null) ? (outDir + "/") : "./";
		System.out.println("[JdbcClient] dirver : " + driverName);
		System.out.println("[JdbcClient] url : " + url);
		System.out.println("[JdbcClient] username : " + username);
		System.out.println("[JdbcClient] outdir : " + outDir);

		try {
			Class.forName(driverName);
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		Connection con = DriverManager.getConnection(url, username, password);
		Statement stmt = con.createStatement();
		System.out.println("[JdbcClient] Running : " + sql + " memory used(MB): " + getUsedMemory());

		ResultSet result = stmt.executeQuery(sql);
		int ncols = result.getMetaData().getColumnCount();
		System.out.println("[JdbcClient] Started to receive records. Column Count : " + ncols);

		FileOutputStream fos = null;
		Writer out = null;
		try {
			fos = new FileOutputStream(new File(outDir + filename), false);
			out = new OutputStreamWriter(new BufferedOutputStream(fos), "UTF-8");

			for (int j = 1; j < (ncols + 1); j++) {
				out.append(result.getMetaData().getColumnName(j));
				if (j < ncols)
					out.append(separator);
				else
					out.append("\r\n");
			}
			int m = 1;
			while (result.next()) {
				for (int k = 1; k < (ncols + 1); k++) {
					out.append(result.getString(k));
					if (k < ncols)
						out.append(separator);
					else
						out.append("\r\n");
				}
				m++;
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			out.close();
			fos.close();
			result.close();
			stmt.close();
			con.close();		
		}
		System.out.println("[JdbcClient] the job is done...");
	}
}
