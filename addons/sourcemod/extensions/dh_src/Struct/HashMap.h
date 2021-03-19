#ifndef __Navigation_hashmap_h__
#define __Navigation_hashmap_h__

#include <cstdlib>
#include <unordered_map>

template <typename K, typename V>
class HashMap {
public:
    HashMap()
    {
        this->items = new std::unordered_map<K, V>();
    }

    ~HashMap()
    {
        delete this->items;
    }

    void Add(K key, V value)
    {
        this->items->insert({ key, value });
    }
    V Get(K key)
    {
        auto got = this->items->find(key);
        if (got != this->items->end())
            return got->second;
        return NULL;
    }

    void Destroy()
    {
        this->items->clear();
        delete this->items;
    }

public:
    std::unordered_map<K, V>* items;
};

#endif