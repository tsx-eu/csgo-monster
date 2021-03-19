#ifndef __Navigation_list_h__
#define __Navigation_list_h__

#include <stddef.h>

#include <sh_vector.h>

template <class T>
class List {
public:
    List()
    {
        this->items = new SourceHook::CVector<T>();
    }

    ~List()
    {
        delete this->items;
    }

    void Destroy()
    {
        delete this;
    }

    bool Insert(T item, unsigned int index)
    {
        size_t size = this->items->size();

        if (index > size) {
            return false;
        }

        this->items->insert(this->items->iterAt(index), item);
        return true;
    }

    void Append(T item)
    {
        this->items->insert(this->items->end(), item);
    }
    void Merge(List<T>* item)
    {
        if (item != NULL) {
            for (unsigned int i = 0; i < item->Size(); i++)
                this->Append(item->At(i));
            item->Destroy();
        }
    }

    void Prepend(T item)
    {
        this->items->insert(this->items->begin(), item);
    }

    T At(unsigned int index)
    {
        return this->items->at(index);
    }

    size_t Size()
    {
        return this->items->size();
    }

    void Erase(unsigned int index)
    {
        this->items->erase(this->items->iterAt(index));
    }

    int Find(T item)
    {
        size_t size = this->items->size();

        for (unsigned int i = 0; i < size; i++) {
            if (this->items->at(i) != item) {
                continue;
            }

            return i;
        }

        return -1;
    }

private:
    SourceHook::CVector<T>* items;
};

#endif
