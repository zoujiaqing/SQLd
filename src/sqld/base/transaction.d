module sqld.base.transaction;

/**
 * Represents abstract transaction
 */
interface ITransaction
{
    ITransaction commit();
    ITransaction save(string);
    ITransaction rollback();
    ITransaction rollbackTo(string);
    ITransaction release();
}