<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/documentation/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** Database username */
define( 'DB_USER', 'wordpress' );

/** Database password */
define( 'DB_PASSWORD', 'Password@123' );

/** Database hostname */
define( 'DB_HOST', '172.31.34.112' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
  *
 * @since 2.6.0
 */
define('AUTH_KEY',         '3U^6^]D?tO}XG,t9rF]QGt^j48I7+vR1CA?,0E+S.u`}+V0_i>nx}S<9jaq?WG^j');
define('SECURE_AUTH_KEY',  '>@^o$JUt&MKufc0FJzz`T<=T!+$|fr79^~[2*8+A@*t=;32NcUhA=ZzrzF!|{M*m');
define('LOGGED_IN_KEY',    '++tIQRO6XsWnEEu$FI{Q-CAwq1..ZpEYL?u0F-d9~-?+(-)|Q;~m+V+)FuT4/UcA');
define('NONCE_KEY',        '5~UEDvgDOLXe.#&|~*!o5strJ$KBgTwL(EEYh)BSm:cgZPDJLc%*`FT</*$+T>)t');
define('AUTH_SALT',        'ctbdipi+-Yn[MIA6LNC_}%+=Ns4EL`-PeN+ErABuZqkh8fu 8hR:+|Z__OE!+8rl');
define('SECURE_AUTH_SALT', '6NEY]LlJ/mroVzp=!ztw,?/0_/cS-m2Q+tHg%q+O:Y|2/XgrwPl={:Q+Ikhfov#/');
define('LOGGED_IN_SALT',   ')w+;Ze4B@_pNByK-<b26r+>{-g|S2A)mX3+7xPk%Yu#cO{!EjIaZzJVC8;>*+1kx');
define('NONCE_SALT',       'Y{uL]Lu=SVA$^VaD|&|wC} 3%QX^}8GsZs-s-+<G%W0<&n~>]8o?*yAW{~Ss?A8:');

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/documentation/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';